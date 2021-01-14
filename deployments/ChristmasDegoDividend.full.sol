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
*/
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

// File: contracts/library/Math.sol

pragma solidity ^0.5.5;

// a library for performing various math operations

library Math {
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

// File: contracts/interface/IGegoToken.sol

pragma solidity ^0.5.0;



contract IGegoToken is IERC721 {

    struct GegoV1 {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 amount;
        uint256 resId;
        address author;
        uint256 createdTime;
        uint256 blockNum;
    }


    struct Gego {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 amount;
        uint256 resBaseId;
        uint256 tLevel;
        uint256 ruleId;
        uint256 nftType;
        address author;
        address erc20;
        uint256 createdTime;
        uint256 blockNum;
    }
    
    function mint(address to, uint256 tokenId) external returns (bool) ;
    function burn(uint256 tokenId) external;
}

// File: contracts/interface/IGegoFactoryV2.sol

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;


interface IGegoFactoryV2 {


    function getGego(uint256 tokenId)
        external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 amount,
            uint256 resBaseId,
            uint256 tLevel,
            uint256 ruleId,
            uint256 nftType,
            address author,
            address erc20,
            uint256 createdTime,
            uint256 blockNum
        );


    function getGegoStruct(uint256 tokenId)
        external view
        returns (IGegoToken.Gego memory gego);

    function burn(uint256 tokenId) external returns ( bool );
    
    function isRulerProxyContract(address proxy) external view returns ( bool );
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

// File: contracts/interface/IChristmasDegoDividendTeam.sol

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

interface IChristmasDegoDividendTeam {
    
    struct Team {
        uint256 gegoId;
        address captain; 
        uint256 captainStatus;// 0 -> not Exist, 1 -> in team, 2 -> leave team

        uint256 initReward;
        
        uint256 captainHadReward;

        // dego
        uint256 totalSupply;
    
        // nft weight + dego weight
        uint256 totalPower;
        
        uint256 rewardRate;
        uint256 lastUpdateTime;
        
        uint256 rewardPerTokenStored;

    }

    function setImplement(address impl, bool tag) external;

    function getImplement(address impl) external view returns (bool);

    function setTeams(uint256 gegoId, Team calldata team) external;

    function getTeams(uint256 gegoId) external view returns (Team memory);

    function setAccBalances(uint256 heroId, address account, uint256 balance) external;

    function getAccBalances(uint256 heroId, address account) external view returns (uint256);

    function setAccPowerBalances(uint256 heroId, address account, uint256 powerBalance) external;

    function getAccPowerBalances(uint256 heroId, address account) external view returns (uint256);

    function deleteAccPlayerGego(uint256 heroId, address account, uint256 gegoId) external;

    function setAccPlayerGego(uint256 heroId, address account, uint256[] calldata gegoIds) external;
    
    function getAccPlayerGego(uint256 heroId, address account) external view returns (uint256[] memory);

    function setAccGegoMapIndex(uint256 heroId, uint256 gegoId, uint256 index) external;

    function getAccGegoMapIndex(uint256 heroId, uint256 gegoId) external view returns (uint256);
    
    function setAccUserRewardPerTokenPaid(uint256 heroId, address account, uint256 rewardPerTokenStored) external;

    function getAccUserRewardPerTokenPaid(uint256 heroId, address account) external view returns (uint256);
 
    function setAccRewards(uint256 heroId, address account, uint256 reward) external;

    function getAccRewards(uint256 heroId, address account) external view returns (uint256);

    function setAccTotalRewards(uint256 heroId, address account, uint256 reward) external;

    function getAccTotalRewards(uint256 heroId, address account) external view returns (uint256);

    function setAccLastStakedTime(uint256 heroId, address account, uint256 stakeTime) external;

    function getAccLastStakedTime(uint256 heroId, address account) external view returns (uint256);

    function setGegoIdPowers(uint256 gegoId, uint256 power) external;

    function getGegoIdPowers(uint256 gegoId) external view returns (uint256);

    function getTeamTotalInitReward(uint256 heroId) external view returns (uint256);

    function setTeamIndexes(uint256 gegoId) external;

    function getTeamIndexes() external view returns (uint256[] memory);

    function rewardPerToken(uint256 heroId ,uint256 lastTimeRewardApplicable) external view returns (uint256);

    function earned(uint256 heroId, address account, uint256 lastTimeRewardApplicable) external view returns (uint256);

    function startDivident(uint256 _lastTimeRewardApplicable, uint256 _duration, uint256 rewards) external returns (uint256);

    function stakeGego(uint256 heroId, uint256 gegoId, uint256 stakePower, address account) external;

    function stakeDego(uint256 heroId, uint256 amount, address account) external;
}

// File: contracts/christmas/Constants.sol

pragma solidity ^0.5.5;





library Constants {
    
    /* Bootstrapping */
    IGegoFactoryV2 private constant GEGOFACTORYV2 = IGegoFactoryV2(0xe5c0c004ABf5585dCACf95893C5866CF59f59b9c);
    IGegoToken private constant GEGOTOKENV2 = IGegoToken(0x36633B70eAC3d1C98A20a6ECEF6033D1077372F5);
    IGegoToken private constant HEROGEGOTOKEN = IGegoToken(0x36633B70eAC3d1C98A20a6ECEF6033D1077372F5);
    IERC20 private constant REWARDTOKEN = IERC20(0x3FdA9383A84C05eC8f7630Fe10AdF1fAC13241CC);
    uint256 private constant REWARDAMOUNT = 75000000000000000000000;
    address private constant TEAMWALLET = 0x3D0a845C5ef9741De999FC068f70E2048A489F2b;
    address private constant REWARDPOOL = 0xEA6dEc98e137a87F78495a8386f7A137408f7722;
    uint256 private constant TEAMDURATION = 2 days;
    uint256 private constant DIVIDENDDURATION = 30 days;
    uint256 private constant PUNISHTIME = 3 days;
    uint256 private constant POOLREWARDRATE = 10000;
    uint256 private constant HEROREWARDRATE = 20000;
    uint256 private constant BASERATE = 100000;
    

    /**
     * Getters
     */
    function getGegoFactoryV2() internal pure returns (IGegoFactoryV2) {
        return GEGOFACTORYV2;
    }

    function getGegoToken() internal pure returns (IGegoToken) {
        return GEGOTOKENV2;
    }

    function getHeroGegoToken() internal pure returns (IGegoToken) {
        return HEROGEGOTOKEN;
    }

    function getRewardToken() internal pure returns (IERC20) {
        return REWARDTOKEN;
    }

    function getRewardAmount() internal pure returns (uint256) {
        return REWARDAMOUNT;
    }

    function getTeamWallet() internal pure returns (address) {
        return TEAMWALLET;
    }

    function getRewardPool() internal pure returns (address) {
        return REWARDPOOL;
    }

    function getTeamDuration() internal pure returns (uint256) {
        return TEAMDURATION;
    }

    function getDividendDuration() internal pure returns (uint256) {
        return DIVIDENDDURATION;
    }

    function getPunishiTime() internal pure returns (uint256) {
        return PUNISHTIME;
    }

    function getPoolRewardRate() internal pure returns (uint256) {
        return POOLREWARDRATE;
    }

    function getHeroRewardRate() internal pure returns (uint256) {
        return HEROREWARDRATE;
    }

    function getBaseRate() internal pure returns (uint256) {
        return BASERATE;
    }
}

// File: contracts/library/ReentrancyGuard.sol

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    function initReentrancyStatus() internal {
        _status = _NOT_ENTERED;
    }
}

// File: contracts/christmas/ChristmasDegoDividend.sol

pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;





contract ChristmasDegoDividend is IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bool private _initialized; // Flag of initialize data
    address public _governance;
    
    IChristmasDegoDividendTeam public _teamimpl = IChristmasDegoDividendTeam(0x0);

    bool public _hasStart = false;
    uint256 public _teamStartTime =  now + 365 days;
    uint256 public _dividentStartTime =  now + 365 days;
    bool public _hasStartDivident = false;
    uint256 public _dividendPeriodFinish = 0;
    mapping (uint256 => bool) public _heros;
    mapping (uint256 => bool) public _outsideActivityGegos;
    mapping(uint256 => Rule) public _rules;
    uint256 public _powerFactorRate = 100000;
    
    struct Rule {
        address erc20;
        uint256 priceRate;
        uint256 decimals;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);
    event evenRewardPaid(address user, uint256 reward);
    event evenRewardAdded(uint256 poolSurplusReward);
    event evenSetStart(uint256 startTime);
    event evenStartNewEpoch(uint256 reward);
    // stake -> 1 // withdraw -> 2
    event evenStakeOrWithdrawHero(address user, uint256 gegoId, uint256 stakeOrWithdraw);
    // stake -> 1
        // stakeGego 12
    // withdraw -> 2
        // withdrawGego 22
    event evenStakeOrWithdraw(address user, uint256 heroId, uint256 gegoIdOrAmount, uint256 stakeOrWithdraw);
    event evenSetHero(uint256 gegoId, bool tag);
    event evenSetOutsideActivityGego(uint256 gegoId, bool tag);
    event evenSetGegoRule(uint256 ruleId, address erc20, uint256 priceRate);
    event evenSetTeamPowerRewardConfig(uint256 index, uint256 num);
    event evenSetPowerFactorRate(uint256 powerFactorRate);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
   
    modifier checkHero(uint256 gegoId) {
        require(_heros[gegoId], "is not hero");
        _; 
    }

    modifier checkOutsideActivityGego(uint256 gegoId) {
        require(!_heros[gegoId], "is a hero");
        require(!_outsideActivityGegos[gegoId], "is a outside activity gego");
        _; 
    }

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    modifier checkNextEpoch {
        if (block.timestamp >= _dividentStartTime) {
            if (_hasStartDivident == false) {
                uint256 totalReward = Constants.getRewardAmount();
                _teamimpl.startDivident(lastTimeRewardApplicable(), Constants.getDividendDuration(), totalReward);
                _dividendPeriodFinish = block.timestamp.add(Constants.getDividendDuration());
                _hasStartDivident = true;   
                emit evenStartNewEpoch(totalReward);
            }
        }
        _;
    }

    modifier updateReward(uint256 heroId, address account) {
        IChristmasDegoDividendTeam.Team memory team =  _teamimpl.getTeams(heroId);
        team.rewardPerTokenStored = rewardPerToken(heroId);
        team.lastUpdateTime = lastTimeRewardApplicable();
        _teamimpl.setTeams(heroId, team);

        if (account != address(0)) {
            uint256 gotReward  = earned(heroId, account);
            uint256 userRewardPerTokenPaid = team.rewardPerTokenStored;
            _teamimpl.setAccRewards(heroId, account, gotReward);
            _teamimpl.setAccUserRewardPerTokenPaid(heroId, account, userRewardPerTokenPaid);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp > _teamStartTime, "not start");
        _;
    }

    // create team
    function stakeHero(uint256 gegoId) public 
        checkHero(gegoId)
        updateReward(gegoId, msg.sender) 
        checkStart
        checkNextEpoch
        nonReentrant
    {
        require(gegoId > 0, "the gegoId error");
        IChristmasDegoDividendTeam.Team memory team = _teamimpl.getTeams(gegoId);
        require(team.captainStatus != 1, "have in team");

        Constants.getHeroGegoToken().safeTransferFrom(msg.sender, address(this), gegoId);
        // create team
        if (team.captainStatus == 0) {
            _teamimpl.setTeamIndexes(gegoId);
            team.gegoId = gegoId;
        }
        team.captainStatus = 1;
        team.captain = msg.sender;
        if (team.totalPower == 0){
            team.totalPower = 1;
        }
        _teamimpl.setTeams(gegoId,team);

        emit evenStakeOrWithdrawHero(msg.sender, gegoId, 1);
    }
    
    // delete team
    function withdrawHero(uint256 gegoId) public 
        checkHero(gegoId)
        updateReward(gegoId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        require(gegoId > 0, "the gegoId error");
        IChristmasDegoDividendTeam.Team memory team = _teamimpl.getTeams(gegoId);
        require(team.captainStatus == 1, "not in team");
        require(team.captain == msg.sender, "the gego not owner captain");
        team.captainStatus = 2;

        Constants.getHeroGegoToken().safeTransferFrom(address(this), team.captain, gegoId);
        _teamimpl.setTeams(gegoId, team);
        emit evenStakeOrWithdrawHero(msg.sender, gegoId, 2);
    }

    // join team
    function stakeGego(uint256 _heroId, uint256 _gegoId)  public 
        updateReward(_heroId, msg.sender) 
        checkStart 
        checkNextEpoch
        nonReentrant
        checkOutsideActivityGego(_gegoId)
    {
        uint256 heroId = _heroId;
        uint256 gegoId = _gegoId;
        Constants.getGegoToken().safeTransferFrom(msg.sender, address(this), gegoId);

        uint256 stakeRate;
        uint256 ercAmount;
        uint256 ruleId;
        uint256 nftType;
        (stakeRate, ercAmount, ruleId, nftType) = getStakeGegoInfo(gegoId); 
        // update power
        Rule memory rule = _rules[ruleId];
        require(rule.erc20 != address(0), "Not conforming to the rules");
        
        require(ercAmount != 0, "ercAmount is zero");
        uint256 amount = ercAmount.mul(1e18).div(10**(rule.decimals));
        amount = amount.mul(rule.priceRate).div(Constants.getBaseRate());
        require(amount != 0, "Not conforming to the rules");
        uint256 stakePower = stakeRate.mul(amount).div(Constants.getBaseRate());

        _teamimpl.stakeGego(heroId, gegoId, stakePower, msg.sender);

        emit evenStakeOrWithdraw(msg.sender, heroId, gegoId, 12);

    }

    function getReward(uint256 heroId) external  
        updateReward(heroId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        uint256 reward = earned(heroId, msg.sender);
        if (reward > 0) {
            IChristmasDegoDividendTeam.Team memory team = _teamimpl.getTeams(heroId);
            _teamimpl.setAccRewards(heroId,msg.sender,0);
            
            uint256 leftReward = reward;
            // 10% pool
            uint256 accLastStakedTime = _teamimpl.getAccLastStakedTime(heroId,msg.sender);
            if(now  < accLastStakedTime.add(Constants.getPunishiTime()) ){
                uint256 poolReward = leftReward.mul(Constants.getPoolRewardRate()).div(Constants.getBaseRate());
                Constants.getRewardToken().safeTransfer(Constants.getRewardPool(), poolReward);
                leftReward = leftReward.sub(poolReward);
            }
            // 20% hero
            
            uint256 heroReward = leftReward.mul(Constants.getHeroRewardRate()).div(Constants.getBaseRate());
            if (team.captainStatus == 1) {
                Constants.getRewardToken().safeTransfer(team.captain, heroReward);
                team.captainHadReward = team.captainHadReward.add(heroReward);
            } else {
                Constants.getRewardToken().safeTransfer(Constants.getTeamWallet(), heroReward);
            }
            leftReward = leftReward.sub(heroReward);
            
            // reward
            _teamimpl.setAccTotalRewards(heroId, msg.sender, leftReward);
            Constants.getRewardToken().safeTransfer(msg.sender, leftReward);
            _teamimpl.setTeams(heroId,team);

            emit evenRewardPaid(msg.sender, leftReward);
            
        }
    }

    function withdraw(uint256 heroId)
        public
        updateReward(heroId, msg.sender) 
        checkStart
        checkNextEpoch
    {
        uint256[] memory gegoIds = _teamimpl.getAccPlayerGego(heroId, msg.sender);
        // uint256[] memory gegoId = _playerGego[msg.sender];
        for (uint8 index = 1; index < gegoIds.length; index++) {
            if (gegoIds[index] > 0) {
                _withdrawGego(heroId, gegoIds[index]);
            }
        }
    }

    function _withdrawGego(uint256 heroId, uint256 gegoId) private {
        
        // update power  
        require(gegoId > 0, "the gegoId error");
        IChristmasDegoDividendTeam.Team memory team = _teamimpl.getTeams(heroId);
        require(team.gegoId != 0, "no team");

        uint256[] memory gegoIds = _teamimpl.getAccPlayerGego(heroId, msg.sender);

        uint256 gegoIndex = _teamimpl.getAccGegoMapIndex(heroId, gegoId);
        
        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        Constants.getGegoToken().safeTransferFrom(address(this), msg.sender, gegoId);

        _teamimpl.deleteAccPlayerGego(heroId, msg.sender, gegoId);

        uint256 withDrawPower = _teamimpl.getGegoIdPowers(gegoId);
        uint256 accPower = _teamimpl.getAccPowerBalances(heroId, msg.sender);
        accPower = accPower.sub(withDrawPower);
        team.totalPower = team.totalPower.sub(withDrawPower);
        _teamimpl.setTeams(heroId, team);
        _teamimpl.setAccPowerBalances(heroId, msg.sender, accPower);

        emit evenStakeOrWithdraw(msg.sender, heroId, gegoId, 22);
    }

    function withdrawGego(uint256 heroId, uint256 gegoId) public
        updateReward(heroId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        // update power  
        require(gegoId > 0, "the gegoId error");
        IChristmasDegoDividendTeam.Team memory team = _teamimpl.getTeams(heroId);
        require(team.gegoId != 0, "no team");

        uint256[] memory gegoIds = _teamimpl.getAccPlayerGego(heroId, msg.sender);

        uint256 gegoIndex = _teamimpl.getAccGegoMapIndex(heroId, gegoId);
        
        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        Constants.getGegoToken().safeTransferFrom(address(this), msg.sender, gegoId);

        _teamimpl.deleteAccPlayerGego(heroId, msg.sender, gegoId);

        uint256 withDrawPower = _teamimpl.getGegoIdPowers(gegoId);
        uint256 accPower = _teamimpl.getAccPowerBalances(heroId, msg.sender);
        accPower = accPower.sub(withDrawPower);
        team.totalPower = team.totalPower.sub(withDrawPower);
        _teamimpl.setTeams(heroId, team);
        _teamimpl.setAccPowerBalances(heroId, msg.sender, accPower);

        emit evenStakeOrWithdraw(msg.sender, heroId, gegoId, 22);
    }

    function getFixRate(uint256 grade,uint256 quality) internal view returns (uint256){

        require(grade > 0 && grade <7, "the gego not token");

        uint256 unfold = 0;
        if( grade == 1 ){
            unfold = quality.mul(10000).div(5000);
            unfold = unfold.add(110000);
        }else if( grade == 2){
            unfold = quality.sub(5000).mul(10000).div(3000);
            unfold = unfold.add(120000);
        }else if( grade == 3){
            unfold = quality.sub(8000).mul(10000).div(1000);
           unfold = unfold.add(130000);
        }else if( grade == 4){
            unfold = quality.sub(9000).mul(20000).div(800);
           unfold = unfold.add(140000);
        }else if( grade == 5){
            unfold = quality.sub(9800).mul(20000).div(180);
            unfold = unfold.add(160000);
        }else{
            unfold = quality.sub(9980).mul(20000).div(20);
            unfold = unfold.add(180000);
        }
        return unfold.mul(_powerFactorRate).div(Constants.getBaseRate()); 
    }

    function getStakeGegoInfo( uint256 gegoId ) public view returns ( uint256 stakeRate, uint256 amount,uint256 ruleId,uint256 nftType){

        uint256 grade;
        uint256 quality; 
        (grade,quality,amount, , ,ruleId, nftType, , , , ) = Constants.getGegoFactoryV2().getGego(gegoId);
        require(amount > 0,"the gego not token");
        stakeRate = getFixRate(grade,quality);
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return Math.min(block.timestamp, _dividendPeriodFinish);
    }

    function rewardPerToken(uint256 heroId) internal view returns (uint256) {
        return _teamimpl.rewardPerToken(heroId,lastTimeRewardApplicable());
    }

    function earned(uint256 heroId, address account) public view returns (uint256) {
        return _teamimpl.earned(heroId,account,lastTimeRewardApplicable());
    }

    // governance
    // --- Init ---
    function initialize(address dividendTeam) public {
        require(!_initialized, "initialize: Already initialized!");
        _governance = tx.origin;
        _hasStart = false;
        _hasStartDivident = false;
        _teamStartTime =  now + 365 days;
        _dividentStartTime =  now + 365 days;
        _powerFactorRate = 100000;
        _teamimpl = IChristmasDegoDividendTeam(dividendTeam);
        initReentrancyStatus();
        
        _initialized = true;
    }

    function setGovernance(address governance) external  onlyGovernance{
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }

    // set start time
    function setStartTime(uint256 startTime) external onlyGovernance {
        require(_hasStart == false, "has started");
        _hasStart = true;
        _teamStartTime = startTime;
        _dividentStartTime = _teamStartTime.add(Constants.getTeamDuration());
        emit evenSetStart(startTime);
    }

    function setHero(uint256 gegoId, bool tag) external onlyGovernance {
        _heros[gegoId] = tag;
        emit evenSetHero(gegoId,tag);
    }

    function setOutsideActivityGego(uint256 gegoId, bool tag) external onlyGovernance {
        _outsideActivityGegos[gegoId] = tag;
        emit evenSetOutsideActivityGego(gegoId,tag);
    }

    function setGegoRule(
        uint256 ruleId,
        address erc20,
        uint256 priceRate,
        uint256 decimals) 
        external 
        onlyGovernance 
    {
        Rule memory rule;
        rule.erc20 = erc20;
        rule.priceRate = priceRate;
        rule.decimals = decimals;
        _rules[ruleId] = rule;
        emit evenSetGegoRule(ruleId, erc20, priceRate);
    }

    function setPowerFactorRate (uint256 powerFactorRate) external onlyGovernance {
        _powerFactorRate = powerFactorRate;
        emit evenSetPowerFactorRate(powerFactorRate);
    }

    /* Fee collection for any other token */
    function seize(IERC20 token, uint256 amount) external {
        require(token != Constants.getRewardToken(), "reward");
        token.safeTransfer(_governance, amount);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        if(_hasStart == false) {
            return 0;
        }

        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
