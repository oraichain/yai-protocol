/**
 *Submitted for verification at Etherscan.io on 2020-08-31
*/

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/hardworkInterface/IController.sol

pragma solidity 0.5.16;

interface IController {
    // [Grey list]
    // An EOA can safely interact with the system no matter what.
    // If you're using Metamask, you're using an EOA.
    // Only smart contracts may be affected by this grey list.
    //
    // This contract will not be able to ban any EOA from the system
    // even if an EOA is being added to the greyList, he/she will still be able
    // to interact with the whole system as if nothing happened.
    // Only smart contracts will be affected by being added to the greyList.
    // This grey list is only used in Vault.sol, see the code there for reference
    function greyList(address _target) external returns (bool);

    function addVaultAndStrategy(address _vault, address _strategy) external;

    function doHardWork(address _vault) external;

    function hasVault(address _vault) external returns (bool);

    function salvage(address _token, uint256 amount) external;

    //    function salvageStrategy(address _strategy, address _token, uint256 amount) external;

    function notifyFee(address _underlying, uint256 fee) external;

    function profitSharingNumerator() external view returns (uint256);

    function profitSharingDenominator() external view returns (uint256);
}

// File: contracts/hardworkInterface/IStrategy.sol

pragma solidity 0.5.16;


interface IStrategy {

    function unsalvagableTokens(address tokens) external view returns (bool);

    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function vault() external view returns (address);

    function withdrawAllToVault() external;

    function withdrawToVault(uint256 amount) external;

    function investedUnderlyingBalance() external view returns (uint256); // itsNotMuch()

    // should only be called by controller
    function salvage(address recipient, address token, uint256 amount) external;

    function doHardWork() external;

    function depositArbCheck() external view returns (bool);
}

// File: contracts/hardworkInterface/IVault.sol

pragma solidity 0.5.16;


interface IVault {
    // the IERC20 part is the share

    function underlyingBalanceInVault() external view returns (uint256);

    function underlyingBalanceWithInvestment() external view returns (uint256);

    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function strategy() external view returns (address);

    function setStrategy(address _strategy) external;

    function setVaultFractionToInvest(uint256 numerator, uint256 denominator) external;

    function deposit(uint256 amountWei) external;

    function depositFor(uint256 amountWei, address holder) external;

    function withdrawAll() external;

    function withdraw(uint256 numberOfShares) external;

    function getPricePerFullShare() external view returns (uint256);

    function underlyingBalanceWithInvestmentForHolder(address holder) view external returns (uint256);

    function investedTokenAmount() external view returns (uint256);

    function availableToInvestOut() external view returns (uint256);

    function announceStrategyUpdate(address _strategy, uint256 when) external;

    function finalizeStrategyUpdate() external;

    // hard work should be callable only by the controller (by the hard worker) or by governance
    function doHardWork() external;

    function rebalance() external;
}

// File: contracts/Storage.sol

pragma solidity 0.5.16;

contract Storage {

    address public governance;
    address public controller;

    constructor() public {
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(isGovernance(msg.sender), "Not governance");
        _;
    }

    function setGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "new governance shouldn't be empty");
        governance = _governance;
    }

    function setController(address _controller) public onlyGovernance {
        require(_controller != address(0), "new controller shouldn't be empty");
        controller = _controller;
    }

    function isGovernance(address account) public view returns (bool) {
        return account == governance;
    }

    function isController(address account) public view returns (bool) {
        return account == controller;
    }
}

// File: contracts/Governable.sol

pragma solidity 0.5.16;


contract Governable {

    Storage public store;

    constructor(address _store) public {
        require(_store != address(0), "new storage shouldn't be empty");
        store = Storage(_store);
    }

    modifier onlyGovernance() {
        require(store.isGovernance(msg.sender), "Not governance");
        _;
    }

    function setStorage(address _store) public onlyGovernance {
        require(_store != address(0), "new storage shouldn't be empty");
        store = Storage(_store);
    }

    function governance() public view returns (address) {
        return store.governance();
    }
}

// Unifying the interface with the Synthetix Reward Pool 
interface IRewardPool {
    function rewardToken() external view returns (address);

    function lpToken() external view returns (address);

    function duration() external view returns (uint256);

    function periodFinish() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function stake(uint256 amountWei) external;

    // `balanceOf` would give the amount staked.
    // As this is 1 to 1, this is also the holder's share
    function balanceOf(address holder) external view returns (uint256);
    // total shares & total lpTokens staked
    function totalSupply() external view returns (uint256);

    function withdraw(uint256 amountWei) external;

    function exit() external;

    // get claimed rewards
    function earned(address holder) external view returns (uint256);

    // claim rewards
    function getReward() external;

    // notify
    function notifyRewardAmount(uint256 _amount) external;
}


// File: contracts/FeeRewardForwarder.sol

pragma solidity 0.5.16;


interface IFeeRewardForwarder {

    function setTokenPool(address _pool) external;


    function setConversionPath(address from, address to, address[] calldata _uniswapRoute) external;

    // Transfers the funds from the msg.sender to the pool
    // under normal circumstances, msg.sender is the strategy
    function poolNotifyFixedTarget(address _token, uint256 _amount) external;
}


interface IHardRewards {

    function rewardMe(address recipient, address vault) external;

    function addVault(address _vault) external;

    function removeVault(address _vault) external;

    function load(address _token, uint256 _rate, uint256 _amount) external;
}

interface IApiConsumer {
    function requestData(bytes calldata data, bytes4 callbackFunctionId, address callbackAddress) external returns (bytes32 requestId);
}


contract Controller is IController, Governable {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    // external parties
    address public feeRewardForwarder;

    // [Grey list]
    // An EOA can safely interact with the system no matter what.
    // If you're using Metamask, you're using an EOA.
    // Only smart contracts may be affected by this grey list.
    //
    // This contract will not be able to ban any EOA from the system
    // even if an EOA is being added to the greyList, he/she will still be able
    // to interact with the whole system as if nothing happened.
    // Only smart contracts will be affected by being added to the greyList.
    mapping(address => bool) public greyList;

    // All vaults that we have
    mapping(address => bool) public vaults;
    address public oracleContract;
    mapping(address => bool) public isRequestFutureVault;
    // Rewards for hard work. Nullable.
    IHardRewards public hardRewards;

    uint256 public constant profitSharingNumerator = 5;
    uint256 public constant profitSharingDenominator = 100;

    event SharePriceChangeLog(
        address indexed vault,
        address indexed strategy,
        uint256 oldSharePrice,
        uint256 newSharePrice,
        uint256 timestamp
    );

    modifier validVault(address _vault){
        require(vaults[_vault], "vault does not exist");
        _;
    }

    mapping(address => bool) public hardWorkers;

    modifier onlyHardWorkerOrGovernance() {
        require(hardWorkers[msg.sender] || (msg.sender == governance()),
            "only hard worker can call this");
        _;
    }

    constructor(address _storage, address _feeRewardForwarder)
    Governable(_storage) public {
        require(_feeRewardForwarder != address(0), "feeRewardForwarder should not be empty");
        feeRewardForwarder = _feeRewardForwarder;
    }

    function setOracleAddress(address _address) external onlyGovernance {
        oracleContract = _address;
    }

    function addHardWorker(address _worker) external onlyGovernance {
        require(_worker != address(0), "_worker must be defined");
        hardWorkers[_worker] = true;
    }

    function removeHardWorker(address _worker) external onlyGovernance {
        require(_worker != address(0), "_worker must be defined");
        hardWorkers[_worker] = false;
    }

    function hasVault(address _vault) external returns (bool) {
        return vaults[_vault];
    }

    // Only smart contracts will be affected by the greyList.
    function addToGreyList(address _target) external onlyGovernance {
        greyList[_target] = true;
    }

    function removeFromGreyList(address _target) external onlyGovernance {
        greyList[_target] = false;
    }

    function setFeeRewardForwarder(address _feeRewardForwarder) external onlyGovernance {
        require(_feeRewardForwarder != address(0), "new reward forwarder should not be empty");
        feeRewardForwarder = _feeRewardForwarder;
    }

    function onlyOracleOrGovernance() private {
        require((oracleContract != address(0) && msg.sender == oracleContract) || (store.isGovernance(msg.sender)), "Invalid oracle");
    }

    function addFutureStrategyAndTime(bytes calldata data) external {
        onlyOracleOrGovernance();
        (address _vault, address  _strategy, uint256 time) = abi.decode(data, (address, address, uint256));
        require(_vault != address(0), "new vault shouldn't be empty");
        require(vaults[_vault], "vault do not exists");
        require(_strategy != address(0), "new strategy shouldn't be empty");
        IVault(_vault).announceStrategyUpdate(_strategy, time);
        isRequestFutureVault[_vault] = false;

    }

    function requestFutureStrategy(address _vault, address _requestConsumer) external onlyHardWorkerOrGovernance {
        require(_vault != address(0), "new vault shouldn't be empty");
        require(vaults[_vault], "vault do not exists");
        require(!isRequestFutureVault[_vault], "Vault is being request future strategy");
        //input data: vaultAddress, investedAmount, availableAmount, token in strategy
        bytes memory data = abi.encode(_vault, IVault(_vault).investedTokenAmount(), IVault(_vault).availableToInvestOut(), IVault(_vault).underlying());
        IApiConsumer(_requestConsumer).requestData(
            data,
            this.addFutureStrategyAndTime.selector,
            address(this)
        );
        isRequestFutureVault[_vault] = true;

    }

    function cancelRequestFutureStragety(address _vault) external onlyHardWorkerOrGovernance {
        require(_vault != address(0), "new vault shouldn't be empty");
        require(vaults[_vault], "vault do not exists");
        IVault(_vault).finalizeStrategyUpdate();
        isRequestFutureVault[_vault] = false;
    }

    function addVaultAndStrategy(address _vault, address _strategy) external onlyGovernance {
        require(_vault != address(0), "new vault shouldn't be empty");
        require(!vaults[_vault], "vault already exists");
        require(_strategy != address(0), "new strategy shouldn't be empty");
        require(IStrategy(_strategy).underlying() == IVault(_vault).underlying(), "Difference underlying in strategy and vault");
        require(IStrategy(_strategy).vault() == _vault, "Vault is not own strategy");
        vaults[_vault] = true;
        // adding happens while setting
        IVault(_vault).setStrategy(_strategy);
    }

    function doHardWork(address _vault) external onlyHardWorkerOrGovernance validVault(_vault) {
        uint256 oldSharePrice = IVault(_vault).getPricePerFullShare();
        IVault(_vault).doHardWork();
        if (address(hardRewards) != address(0)) {
            // rewards are an option now
            hardRewards.rewardMe(msg.sender, _vault);
        }
        emit SharePriceChangeLog(
            _vault,
            IVault(_vault).strategy(),
            oldSharePrice,
            IVault(_vault).getPricePerFullShare(),
            block.timestamp
        );
    }

    function rebalance(address _vault) external onlyHardWorkerOrGovernance validVault(_vault) {
        IVault(_vault).rebalance();
    }

    function setHardRewards(address _hardRewards) external onlyGovernance {
        hardRewards = IHardRewards(_hardRewards);
    }

    // transfers token in the controller contract to the governance
    function salvage(address _token, uint256 _amount) external onlyGovernance {
        IERC20(_token).safeTransfer(governance(), _amount);
    }

    function notifyFee(address underlying, uint256 fee) external {
        if (fee > 0) {
            IERC20(underlying).safeTransferFrom(msg.sender, address(this), fee);
            IERC20(underlying).safeApprove(feeRewardForwarder, 0);
            IERC20(underlying).safeApprove(feeRewardForwarder, fee);
            IFeeRewardForwarder(feeRewardForwarder).poolNotifyFixedTarget(underlying, fee);
        }
    }
}