pragma solidity 0.5.16;

contract OraiTokenReceiver {

    //    bytes4 constant private ORACLE_REQUEST_SELECTOR = 0x40429946;
    uint256 constant private SELECTOR_LENGTH = 4;
    uint256 constant private EXPECTED_REQUEST_WORDS = 2;
    uint256 constant private MINIMUM_REQUEST_LENGTH = SELECTOR_LENGTH + (32 * EXPECTED_REQUEST_WORDS);

    function onTokenTransfer(
        address _sender,
        uint256 _amount,
        bytes memory _data
    )
    public
    onlyOrai
    validRequestLength(_data)
    {
        assembly {
            mstore(add(_data, 36), _sender) // ensure correct sender is passed
            mstore(add(_data, 68), _amount)    // ensure correct amount is passed
        }
        (bool success,) = address(this).delegatecall(_data);
        require(success, "Unable to create request");
    }

    function getOraichainToken() public view returns (address);


    modifier onlyOrai() {
        require(msg.sender == getOraichainToken(), "Must use Orai token");
        _;
    }

    modifier validRequestLength(bytes memory _data) {
        require(_data.length >= MINIMUM_REQUEST_LENGTH, "Invalid request length");
        _;
    }
}

interface OracleRequestInterface {
    function oracleRequest(
        address sender,
        uint256 requestPrice,
        bytes32 serviceAgreementID,
        address callbackAddress,
        bytes4 callbackFunction,
        uint256 nonce,
        bytes calldata data
    ) external;
}

interface OracleInterface {
    function fulfillOracleRequest(
        bytes32 requestId,
        address callbackAddress,
        bytes4 callbackFunctionId,
        bytes calldata data
    ) external returns (bool);

    function getAuthorizationStatus(address node) external view returns (bool);

    function setFulfillmentPermission(address node, bool allowed) external;

    function withdraw(uint256 amount) external;
    //
    //    function withdrawable() external view returns (uint256);
}

interface OraiTokenInterface {
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    function approve(address spender, uint256 value) external returns (bool success);

    function balanceOf(address owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 decimalPlaces);

    function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

    function increaseApproval(address spender, uint256 subtractedValue) external;

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function totalSupply() external view returns (uint256 totalTokensIssued);

    function transfer(address to, uint256 value) external returns (bool success);

    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

    function transferFrom(address from, address to, uint256 value) external returns (bool success);
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract Oracle is OracleRequestInterface, OracleInterface, Ownable, OraiTokenReceiver {
    using SafeMath for uint256;

    uint256 constant private MINIMUM_CONSUMER_GAS_LIMIT = 400000;
    mapping(bytes32 => uint256) public paymentFee;
    mapping(address => uint256) public rewardClaim;

    OraiTokenInterface internal OraiToken;
    mapping(bytes32 => bytes32) public commitments;
    mapping(address => bool) private authorizedNodes;

    event OracleRequest(
        address requester,
        bytes32 requestId,
        bytes32 jobId,
        uint256 payment,
        address callbackAddr,
        bytes4 callbackFunction,
        bytes data
    );


    constructor(address _token)
    public
    Ownable()
    {
        OraiToken = OraiTokenInterface(_token);
        // external but already deployed and unalterable
    }


    /**
     * @notice Creates the request
     * @dev Stores the hash of the params as the on-chain commitment for the request.
     * Emits OracleRequest event for the validator to detect.
     * @param _sender The sender of the request
     * @param _payment The amount of payment given (specified in wei)
     * @param _specId The Job Specification ID
     * @param _callbackAddress The callback address for the response
     * @param _callbackFunction The callback function ID for the response
     * @param _nonce The nonce sent by the requester
     * @param data The data of the request
     */
    function oracleRequest(
        address _sender,
        uint256 _payment,
        bytes32 _specId,
        address _callbackAddress,
        bytes4 _callbackFunction,
        uint256 _nonce,
        bytes calldata data
    )
    external
    onlyOrai()
    checkCallbackAddress(_callbackAddress)
    {
        bytes32 requestId = keccak256(abi.encodePacked(_sender, _nonce));
        require(commitments[requestId] == 0, "Must use a unique ID");
        commitments[requestId] = keccak256(
            abi.encodePacked(
                _callbackAddress,
                _callbackFunction
            )
        );
        paymentFee[requestId] = _payment;
        emit OracleRequest(
            _sender,
            requestId,
            _specId,
            _payment,
            _callbackAddress,
            _callbackFunction,
            data
        );
    }

    /**
    * @notice Allows validator fulfill data to callbackAddress contract and in function callbackFunctionId
    * Remove commitments requestId
    * Add reward claim to validator
    * @param _requestId The request ID
    * @param _callbackAddress The address contract to fulfill data
    * @param _callbackFunctionId The function to call in callbackAddress
    * @param _data The encoded data to fill in function in _callbackAddress
    */
    function fulfillOracleRequest(
        bytes32 _requestId,
        address _callbackAddress,
        bytes4 _callbackFunctionId,
        bytes calldata _data
    )
    external
    onlyAuthorizedNode
    isValidRequest(_requestId)
    returns (bool)
    {
        bytes32 paramsHash = keccak256(
            abi.encodePacked(
                _callbackAddress,
                _callbackFunctionId
            )
        );
        require(commitments[_requestId] == paramsHash, "Params do not match request ID");
        require(gasleft() >= MINIMUM_CONSUMER_GAS_LIMIT, "Must provide consumer enough gas");
        delete commitments[_requestId];
        rewardClaim[msg.sender] += paymentFee[_requestId];
        (bool success,) = _callbackAddress.call(abi.encodeWithSelector(_callbackFunctionId, _data));

        return success;
    }


    function getAuthorizationStatus(address _node)
    external
    view
    returns (bool)
    {
        return authorizedNodes[_node];
    }


    /**
    * @notice Set permission for node
    * Only nodes in authorizedNodes is allowance call fulfillOracleRequest
    * @param _node The node address
    * @param _allowed The permission
    */
    function setFulfillmentPermission(address _node, bool _allowed)
    external
    onlyOwner()
    {
        authorizedNodes[_node] = _allowed;
    }


    /**
    * @notice Withdraw request fee for validator
    * @dev Only when msg.sender == owner or msg.sender = validator and token fee of this address > _amount
    * @param _amount The amount to withdraw
    */
    function withdraw(uint256 _amount)
    external
    hasAvailableFunds(_amount)
    {
        assert(OraiToken.transfer(msg.sender, _amount));
    }

    function withdrawAll()
    external
    {
        require(OraiToken.balanceOf(address(this)) >= rewardClaim[msg.sender], "Amount requested is greater than withdrawable balance");
        assert(OraiToken.transfer(msg.sender, rewardClaim[msg.sender]));
    }


    function getOraichainToken()
    public
    view
    returns (address)
    {
        return address(OraiToken);
    }


    modifier hasAvailableFunds(uint256 _amount) {
        require(OraiToken.balanceOf(address(this)) >= _amount, "Amount requested is greater than withdrawable balance");
        if (!isOwner()) {
            require(rewardClaim[msg.sender] >= _amount, "Amount requested is greater than rewardClaim of msg.sender");
        }
        _;
    }


    modifier isValidRequest(bytes32 _requestId) {
        require(commitments[_requestId] != 0, "Must have a valid requestId");
        _;
    }

    modifier onlyAuthorizedNode() {
        require(authorizedNodes[msg.sender] || msg.sender == owner(), "Not an authorized node to fulfill requests");
        _;
    }


    modifier checkCallbackAddress(address _to) {
        require(_to != address(OraiToken), "Cannot callback to Orai");
        _;
    }

}