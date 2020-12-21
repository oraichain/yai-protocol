pragma solidity 0.5.16;


library Oraichain {


    struct Request {
        bytes32 id;
        address callbackAddress;
        bytes4 callbackFunction;
        uint256 nonce;
        bytes data;
    }


    function initialize(
        Request memory self,
        bytes32 _id,
        address _callbackAddress,
        bytes4 callbackFunction
    ) internal pure returns (Request memory) {
        self.id = _id;
        self.callbackAddress = _callbackAddress;
        self.callbackFunction = callbackFunction;
        return self;
    }


    function addData(Request memory self, bytes  memory _data)
    internal pure
    {
        self.data = _data;
    }
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

contract OraichainClient {
    using Oraichain for Oraichain.Request;
    using SafeMath for uint256;

    uint256 constant internal ORAI = 10 ** 18;
    uint256 constant private AMOUNT_OVERRIDE = 0;
    address constant private SENDER_OVERRIDE = address(0);

    OraiTokenInterface private orai;
    OracleRequestInterface private oracle;
    uint256 private requestCount = 1;
    mapping(bytes32 => address) private pendingRequests;

    event Requested(bytes32 indexed id);
    event Fulfilled(bytes32 indexed id);


    function buildOraichainRequest(
        bytes32 _specId,
        address _callbackAddress,
        bytes4 _callbackFunction
    ) internal pure returns (Oraichain.Request memory) {
        Oraichain.Request memory req;
        return req.initialize(_specId, _callbackAddress, _callbackFunction);
    }

    function sendOraichainRequest(Oraichain.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
    {
        return sendOraichainRequestTo(address(oracle), _req, _payment);
    }

    function sendOraichainRequestTo(address _oracle, Oraichain.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
    {
        requestId = keccak256(abi.encodePacked(this, requestCount));
        _req.nonce = requestCount;
        pendingRequests[requestId] = _oracle;
        emit Requested(requestId);
        require(orai.transferAndCall(_oracle, _payment, encodeRequest(_req)), "unable to transferAndCall to oracle");
        requestCount += 1;

        return requestId;
    }


    function setOraichainOracle(address _oracle) internal {
        oracle = OracleRequestInterface(_oracle);
    }


    function setPublicOraichainToken(address _token) internal {
        orai = OraiTokenInterface(_token);
    }


    function oraichainTokenAddress()
    internal
    view
    returns (address)
    {
        return address(orai);
    }


    function oraichainOracleAddress()
    internal
    view
    returns (address)
    {
        return address(oracle);
    }


    function encodeRequest(Oraichain.Request memory _req)
    private
    view
    returns (bytes memory)
    {
        return abi.encodeWithSelector(
            oracle.oracleRequest.selector,
            SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
            AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
            _req.id,
            _req.callbackAddress,
            _req.callbackFunction,
            _req.nonce,
            _req.data
        );
    }


    function validateOraichainCallback(bytes32 _requestId)
    internal
    recordOraichainFulfillment(_requestId)
        // solhint-disable-next-line no-empty-blocks
    {}


    modifier recordOraichainFulfillment(bytes32 _requestId) {
        require(msg.sender == pendingRequests[_requestId],
            "Source must be the oracle of the request");
        delete pendingRequests[_requestId];
        emit Fulfilled(_requestId);
        _;
    }


    modifier notPendingRequest(bytes32 _requestId) {
        require(pendingRequests[_requestId] == address(0), "Request is already pending");
        _;
    }
}

pragma solidity 0.5.16;


contract APIConsumer is OraichainClient {

    uint256 public volume;
    address private _owner;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    mapping(address => bool) requesterPermission;

    constructor(address _oracle, address _token) public {
        _owner = msg.sender;
        setPublicOraichainToken(_token);
        oracle = _oracle;
        jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
        fee = 0.001 * 10 ** 18;

    }
    function requireOwner() private {
        require(msg.sender == _owner, "Forbidden owner");
    }

    function requireOwnerOrRequester() private {
        require(msg.sender == _owner || requesterPermission[msg.sender], "Forbidden owner or requested permission");
    }

    function changeOwner(address _newOwner) public {
        requireOwner();
        _owner = _newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function setRequesterPermission(address requester, bool allowed) public {
        requireOwner();
        requesterPermission[requester] = allowed;
    }

    function requestData(bytes memory data, bytes4 callbackFunctionId, address callbackAddress) public returns (bytes32 requestId)
    {
        requireOwnerOrRequester();
        require(callbackAddress != address(0), "Callback address = 0");
        Oraichain.Request memory request = buildOraichainRequest(jobId, callbackAddress, callbackFunctionId);
        request.addData(data);
        return sendOraichainRequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, bytes memory data) public recordOraichainFulfillment(_requestId)
    {
        require(msg.sender == oracle, "Forbidden fulfill");
        (uint256 _volume) = abi.decode(data, (uint256));
        volume = _volume;
    }


    function withdrawOrai() external {
        requireOwner();
        OraiTokenInterface oraiToken = OraiTokenInterface(oraichainTokenAddress());
        require(oraiToken.transfer(msg.sender, oraiToken.balanceOf(address(this))), "Unable to transfer");
    }
}