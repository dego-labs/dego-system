/***
 *    ██████╗ ███████╗ ██████╗  ██████╗ 
 *    ██╔══██╗██╔════╝██╔════╝ ██╔═══██╗
 *    ██║  ██║█████╗  ██║  ███╗██║   ██║
 *    ██║  ██║██╔══╝  ██║   ██║██║   ██║
 *    ██████╔╝███████╗╚██████╔╝╚██████╔╝
 *    ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ 
 *    
 * https://dego.finance
                                  
* MIT License
* ===========
*
* Copyright (c) 2020 dego
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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

// File: @openzeppelin/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

pragma solidity ^0.5.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

// File: contracts/interface/IERC20.sol

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
    function mint(address account, uint amount) external;
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
        assembly { codehash := extcodehash(account) }
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
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: contracts/library/SafeERC20.sol

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

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/reward/AuctionHubReward.sol

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;







contract AuctionHubReward is IERC721Receiver {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _dandy = IERC20(0x0);
    uint256 public _rewardDandy = 1e16;
    uint256 _maxAddTime = 1 hours;
    bool private _initialized; // Flag of initialize data
    address public _governance;

    struct AuctioinObject {
        uint turn;

        address origin;
        IERC721 nft;
        address payable nftAuctionWallet;

        address payable curPlayer;

        uint256 baseRate;
        uint256 stepRate;
        uint256 rewardBackRate;

        uint256 startTime;
        uint256 durationTime;
        uint256 stepTime;

        uint256 curAuctionQuote;
        uint256 curTokenId;

        bool isTake;
        bool isStart;
    }

    uint256 public _auctionAmount = 0;

    AuctioinObject[] _auctioinObjects;
    uint8[] public _auctionStatus;

    mapping(address => bool) public _auctioneer;
    mapping(address => bool) public _verifyAuctioneer;
    bool public _isStartUserAuction;

    mapping (address => mapping (uint => uint256)) public _quoteHistory;
    mapping (address => mapping (uint => uint256)) public _earnHistory;

    event eveAuction(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveTurnEnd(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveNewTurn(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveNewAuction(uint256 amount,address auctioneer, uint256 startQuote,uint256 startTime);

    event eveNFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event eveNFTPassBy(uint256 tokenId, uint256 curAuctioinQuote);
    
    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    /**
     * check address
     */
    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        _;
    }

    modifier mustInAuctionTime(uint index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.startTime < now, "not start");
        require(obj.startTime.add(obj.durationTime) > now, "finish");
        _;
    }

    modifier checkTime(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        startCheck(obj);
        _;
    }

    modifier checkindex(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        _;
    }

    // modifier mustEndAuction(AuctioinObject obj) {
    //     require(obj.startTime.add(obj.durationTime) < now, "not finish");
    //     _;
    // }

    modifier mustEndAuction(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.startTime.add(obj.durationTime) < now, "not finish");
        _;
    }

    modifier onlyAuctionOwner(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.origin == msg.sender || msg.sender == _governance, "author & governance");
        _;
    }


    // governance
    // --- Init ---
    function initialize() public {

        require(!_initialized, "initialize: Already initialized!");
        _governance = tx.origin;
        _rewardDandy = 1e16;
        _maxAddTime = 1 hours;
        _initialized = true;
    }


    function seize(IERC20 asset) external onlyGovernance returns (uint256 balance) {
        balance = asset.balanceOf(address(this));
        asset.safeTransfer(_governance, balance);
    }

    function() external payable {
        // auction();
        revert();
    }

    function setRewardDandy(uint256 rewardDandy) public onlyGovernance {
        _rewardDandy = rewardDandy;
    }

    function addAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _auctioneer[auctioneer] = true;
    }

    function removeAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _auctioneer[auctioneer] = false;
    }

    function addVerifyAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _verifyAuctioneer[auctioneer] = true;
    }

    function removeVerifyAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _verifyAuctioneer[auctioneer] = false;
    }

    function setIsStartUserAuction(bool isStartUserAuction) public onlyGovernance {
        _isStartUserAuction = isStartUserAuction;
    }

    function getAuctionEndTime(uint index) 
        external
        view
        checkindex(index)
        returns (uint256) 
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        return obj.startTime.add(obj.durationTime);
    }

    function getAuction(uint index) external view checkindex(index) returns(AuctioinObject memory) {
        return _auctioinObjects[index];
    }

    function getAucitonQuote(uint index)
        external
        view
        checkindex(index)
        returns (uint256)
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        if(obj.curPlayer != address(0x0)) {
            return obj.curAuctionQuote.add(obj.curAuctionQuote.mul(obj.stepRate).div(obj.baseRate));
        } else {
            return obj.curAuctionQuote;
        }
        
    }

    function setDandyAddress(address addr) external onlyGovernance validAddress(addr) {
        _dandy = IERC20(addr);
    }

    function setMaxAddTime(uint256 maxAddTime) external onlyGovernance {
        _maxAddTime = maxAddTime;
    }

    function setBaseRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(rate >= obj.rewardBackRate, "invalid base rate");
        obj.baseRate = rate;
    }

    function setRewardBackRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(rate <= obj.baseRate, "invalid reward return back rate");
        obj.rewardBackRate = rate;
    }

    function setStepRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.stepRate = rate;
    }

    function setDurationTime(uint index, uint256 duration) external onlyAuctionOwner(index) {
        uint status = _auctionStatus[index];
        require(status == 0 || status == 1, "has over");
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.durationTime = duration;
    }

    function setStepTime(uint index, uint256 stepTime) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.stepTime = stepTime;
    }

    function setStartTime(uint index, uint256 startTime) external onlyAuctionOwner(index) {
        uint status = _auctionStatus[index];
        require(status == 0, "has start");
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.startTime = startTime;
    }


    function setGovernance(address governance) external  onlyGovernance{
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


    function getHistory(uint index) public view checkindex(index) returns(uint256 quote, uint256 earn) {
        quote = _quoteHistory[msg.sender][index];
        earn = _earnHistory[msg.sender][index];
    }

    function isVerifyAuction(uint index) public view checkindex(index) returns(bool) {
        AuctioinObject storage obj = _auctioinObjects[index];
        return _verifyAuctioneer[obj.origin];
    }

    function startAuction(uint256 tokenId,
                        uint256 startQuote, 
                        uint256 startTime, 
                        uint256 durationTime,
                        uint256 stepTime,
                        address nft,
                        address payable nftAuctionWallet)
        external 
        validAddress(nft)
        validAddress(nftAuctionWallet)
    {
        require(tokenId != 0, "invalid token");
        require(startTime.add(durationTime) > now, "invalid time");
        require(durationTime != 0, "invalid duration");
        require(_isStartUserAuction || _auctioneer[msg.sender] == true, "cannot auction");

        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        AuctioinObject memory obj;

        obj.nft = IERC721(nft);
        obj.nftAuctionWallet = nftAuctionWallet;
        obj.baseRate = 1000;
        obj.stepRate = 100;
        obj.rewardBackRate = 800;
        obj.curTokenId = tokenId;
        obj.curAuctionQuote = startQuote;
        obj.startTime = startTime;
        obj.durationTime = durationTime;
        obj.stepTime = stepTime;
        obj.curPlayer = address(0x0);
        obj.origin = msg.sender;
        obj.isTake = false;

        _auctionAmount++;
        obj.turn = _auctionAmount;
        obj.isStart = false;

        _auctioinObjects.push(obj);
        _auctionStatus.push(0);

        emit eveNewAuction(_auctionAmount, msg.sender, startQuote, startTime);
    }

    function getReward(uint index) external checkTime(index) mustEndAuction(index) returns(bool) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(!obj.isTake, "nft has been taken");

        if(obj.curPlayer == address(0x0)) {
            obj.nft.safeTransferFrom(address(this), obj.origin, obj.curTokenId);
        } else {
            obj.nft.safeTransferFrom(address(this), obj.curPlayer, obj.curTokenId);
        }
        obj.isTake = true;
        return true;
    }

    function endCheck(AuctioinObject storage obj) internal {
        if( !obj.isStart ){
            return;
        }
        if(obj.startTime.add(obj.durationTime) > now){
            return;
        }

        obj.isTake = false;
        obj.isStart = false;
        _auctionStatus[obj.turn - 1] = 2;

        emit eveTurnEnd( obj.turn, obj.curPlayer, obj.curAuctionQuote, obj.durationTime);
    }

    function startCheck(AuctioinObject storage obj) internal {
        if (obj.isStart) {
            endCheck(obj);
            return;
        }

        if(obj.startTime < now && obj.startTime.add(obj.durationTime) > now) {
            obj.isStart = true;
            _auctionStatus[obj.turn - 1] = 1;
            // _curAuctionQuote = 0;
            obj.curPlayer = address(0x0);
            emit eveNewTurn( obj.turn, obj.curPlayer, obj.curAuctionQuote, obj.durationTime);
        }
    }

    function auction(uint index)
        public
        mustInAuctionTime(index)
        checkTime(index)
        payable 
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        require( obj.isStart, "auction do not open yet!");
        require (msg.value >= this.getAucitonQuote(index), "umm.....  your quote is too low");
        uint256 back = msg.value.sub(this.getAucitonQuote(index));
        if(back > 0) {
            msg.sender.transfer(back);
        }
        uint256 realAuction = msg.value.sub(back);
        if(obj.curPlayer != address(0x0)) {
            uint256 spread = realAuction.sub(obj.curAuctionQuote);
            uint256 returnRewardAmount = spread.mul(obj.rewardBackRate).div(obj.baseRate);
            uint256 returnBackAmount = obj.curAuctionQuote.add(returnRewardAmount);

            obj.curPlayer.transfer(returnBackAmount);

            _earnHistory[obj.curPlayer][index] = _earnHistory[obj.curPlayer][index].add(returnRewardAmount);

            uint256 rewardAmount = spread.sub(returnRewardAmount);
            if(rewardAmount > 0) {
                obj.nftAuctionWallet.transfer(rewardAmount);
            }
        } else {
            obj.nftAuctionWallet.transfer(realAuction);
        }

        if(this.isVerifyAuction(index)) {
            _dandy.mint(msg.sender, _rewardDandy);
        }

        obj.curAuctionQuote = realAuction;
        obj.curPlayer = msg.sender;
        _quoteHistory[msg.sender][index] = realAuction;

        uint256 endTime = this.getAuctionEndTime(index);
        uint256 offset = endTime.sub(now);
        if(offset <= _maxAddTime) {
            uint256 slot = _maxAddTime.sub(offset);
            if(slot <= obj.stepTime) {
                obj.durationTime = obj.durationTime.add(slot);
            } else {
                obj.durationTime = obj.durationTime.add(obj.stepTime);
            }
        }
        
        // fire event
        emit eveAuction(index, msg.sender, realAuction, obj.durationTime);
    }

    function getAuctionsStatus() public view returns(uint8[] memory) {
        return _auctionStatus;
    }
    

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        //only receive the _nft staff
        if(address(this) != operator) {
            //invalid from nft
            return 0;
        }

        //success
        emit eveNFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
