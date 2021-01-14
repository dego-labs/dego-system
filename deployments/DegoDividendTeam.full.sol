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
*/// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: contracts/interface/IDegoDividendTeam.sol

pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

interface IDegoDividendTeam {
    
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

    function startNextEpoch(uint256 _lastTimeRewardApplicable, uint256 _duration, uint256[] calldata powers, uint256[] calldata rewards,uint256 _cycleTimes) external returns (uint256);
    
    function stakeGego(uint256 heroId, uint256 gegoId, uint256 stakePower, address account) external;

    function stakeDego(uint256 heroId, uint256 amount, address account) external;
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

// File: contracts/dividend/DegoDividendTeam.sol

pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;




contract DegoDividendTeam is IDegoDividendTeam {

    using SafeMath for uint256;
    
    bool private _initialized; // Flag of initialize data
    address public _governance;

    mapping(uint256 => Team) private _teams;
    mapping(uint256 => uint256) private _teamTotalInitReward;

    // uint256 ;
    mapping(uint256 => mapping(address => uint256)) private _accBalances;
    mapping(uint256 => mapping(address => uint256)) private _accPowerBalances;

    // stage gego
    mapping(uint256 => mapping(address => uint256[])) private _accPlayerGego;
    mapping(uint256 => mapping(uint256 => uint256)) private _accGegoMapIndex;

    mapping(uint256 => mapping(address => uint256)) private _accUserRewardPerTokenPaid;
    mapping(uint256 => mapping(address => uint256)) private _accRewards;
    mapping(uint256 => mapping(address => uint256)) private _accLastStakedTime;

    uint256[] private _teamIndexes;
    
    mapping(uint256 => uint256) private _gegoIdPowers;
    mapping(address => bool) private _implements;

    mapping(uint256 => mapping(address => uint256)) private _accTotalRewards;
    
    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    modifier onlyImplement {
        require(_implements[msg.sender], "is not implement");
        _;
    }

    function setImplement(address impl, bool tag) external onlyGovernance {
        _implements[impl] = tag;
    }

    function getImplement(address impl) external view returns (bool) {
        return _implements[impl];
    }

    function setTeams(uint256 gegoId, Team calldata team) external onlyImplement {
        _teams[gegoId].gegoId = team.gegoId;
        _teams[gegoId].captain = team.captain;

        _teams[gegoId].captainStatus = team.captainStatus;

        _teams[gegoId].initReward = team.initReward;
        _teams[gegoId].captainHadReward = team.captainHadReward;
        _teams[gegoId].totalSupply = team.totalSupply;
        _teams[gegoId].totalPower = team.totalPower;

        _teams[gegoId].rewardRate = team.rewardRate;
        _teams[gegoId].lastUpdateTime = team.lastUpdateTime;
        _teams[gegoId].rewardPerTokenStored = team.rewardPerTokenStored;
    }

    function getTeams(uint256 gegoId) external view returns (Team memory) {
        return _teams[gegoId];
    }

    function setAccBalances(uint256 heroId, address account, uint256 balance) external onlyImplement {
        _accBalances[heroId][account] = balance;
    }

    function getAccBalances(uint256 heroId, address account) external view returns (uint256) {
        return _accBalances[heroId][account];
    }

    function setAccPowerBalances(uint256 heroId, address account, uint256 powerBalance) external onlyImplement {
        _accPowerBalances[heroId][account] = powerBalance;
    }

    function getAccPowerBalances(uint256 heroId, address account) external view returns (uint256) {
        return _accPowerBalances[heroId][account];
    }

    function deleteAccPlayerGego(uint256 heroId, address account, uint256 gegoId) external onlyImplement{
        uint256 gegoIndex = _accGegoMapIndex[heroId][gegoId];
        uint256[] memory gegoIds = _accPlayerGego[heroId][account];
        uint256 gegoArrayLength = gegoIds.length-1;
        uint256 tailId = gegoIds[gegoArrayLength];

        _accPlayerGego[heroId][account][gegoIndex] = tailId;
        _accPlayerGego[heroId][account][gegoArrayLength] = 0;
        _accPlayerGego[heroId][account].length--;
        _accGegoMapIndex[heroId][tailId] = gegoIndex;
        _accGegoMapIndex[heroId][gegoId] = 0;
    }
    
    function setAccPlayerGego(uint256 heroId, address account, uint256[] calldata gegoIds) external onlyImplement {
        _accPlayerGego[heroId][account] = gegoIds;
    }

    function getAccPlayerGego(uint256 heroId, address account) external view returns (uint256[] memory) {
        uint256[] memory accPlayerGego = new uint256[](_accPlayerGego[heroId][account].length);
        accPlayerGego = _accPlayerGego[heroId][account];
        return accPlayerGego;
    }

    function setAccGegoMapIndex(uint256 heroId, uint256 gegoId, uint256 index) external onlyImplement {
        _accGegoMapIndex[heroId][gegoId] = index;
    }

    function getAccGegoMapIndex(uint256 heroId, uint256 gegoId) external view returns (uint256) {
        return _accGegoMapIndex[heroId][gegoId];
    }
    
    function setAccUserRewardPerTokenPaid(uint256 heroId, address account, uint256 rewardPerTokenStored) external onlyImplement {
        _accUserRewardPerTokenPaid[heroId][account] = rewardPerTokenStored;
    }

    function getAccUserRewardPerTokenPaid(uint256 heroId, address account) external view returns (uint256) {
        return _accUserRewardPerTokenPaid[heroId][account];
    }
 
    function setAccRewards(uint256 heroId, address account, uint256 reward) external onlyImplement {
        _accRewards[heroId][account] = reward;
    }

    function getAccRewards(uint256 heroId, address account) external view returns (uint256) {
        return _accRewards[heroId][account];
    }

    function setAccTotalRewards(uint256 heroId, address account, uint256 reward) external onlyImplement {
        _accTotalRewards[heroId][account] = _accTotalRewards[heroId][account].add(reward);
    }

    function getAccTotalRewards(uint256 heroId, address account) external view returns (uint256) {
        return _accTotalRewards[heroId][account];
    }

    function setAccLastStakedTime(uint256 heroId, address account, uint256 stakeTime) external onlyImplement {
        _accLastStakedTime[heroId][account] = stakeTime;
    }

    function getAccLastStakedTime(uint256 heroId, address account) external view returns (uint256) {
        return _accLastStakedTime[heroId][account];
    }

    function setGegoIdPowers(uint256 gegoId, uint256 power) external onlyImplement {
        _gegoIdPowers[gegoId] = power;
    }

    function getGegoIdPowers(uint256 gegoId) external view returns (uint256) {
        return _gegoIdPowers[gegoId];
    }

    function getTeamTotalInitReward(uint256 heroId) external view returns (uint256) {
        return _teamTotalInitReward[heroId];
    }

    function setTeamIndexes(uint256 gegoId) external onlyImplement {
        _teamIndexes.push(gegoId);
    }

    function getTeamIndexes() external view returns (uint256[] memory) {
        return _teamIndexes;
    }

    function rewardPerToken_internal(uint256 heroId ,uint256 lastTimeRewardApplicable) internal view returns (uint256) {
        Team storage team = _teams[heroId];
        if (team.totalPower == 0) {
            return team.rewardPerTokenStored;
        }
        return
            team.rewardPerTokenStored.add(
                lastTimeRewardApplicable
                    .sub(team.lastUpdateTime)
                    .mul(team.rewardRate)
                    .mul(1e18)
                    .div(team.totalPower)
            );
    }

    function rewardPerToken(uint256 heroId, uint256 lastTimeRewardApplicable) external view returns (uint256) {
        return rewardPerToken_internal(heroId, lastTimeRewardApplicable);
    }

    function earned(uint256 heroId, address account, uint256 lastTimeRewardApplicable) external view returns (uint256) {
        return
            _accPowerBalances[heroId][account]
                .mul(rewardPerToken_internal(heroId, lastTimeRewardApplicable).sub(_accUserRewardPerTokenPaid[heroId][account]))
                .div(1e18)
                .add(_accRewards[heroId][account]);
    }

    function startNextEpoch(uint256 _lastTimeRewardApplicable, uint256 _duration, uint256[] calldata powers, uint256[] calldata rewards,uint256 _cycleTimes) external onlyImplement returns (uint256){
        // dispatch team, computer rewardRate
        uint256 totalPower = 0;
        uint256 duration = _duration;
        uint256 lastTimeRewardApplicable = _lastTimeRewardApplicable;
        uint256 teamLen = _teamIndexes.length;
        Team[] memory captainExistArray = new Team[](teamLen);
        uint256 teamIndex = 0;
        _cycleTimes;
        // totalPower
        for (uint256 i = 0; i < teamLen; i++) {
            uint256 gegoId = _teamIndexes[i];
            Team memory team = _teams[gegoId];
            if (team.captainStatus == 1 && team.totalPower >0 ) {
                totalPower = totalPower.add(team.totalPower);
                captainExistArray[teamIndex] = team;
                teamIndex++;
            }else{
                team.rewardPerTokenStored = rewardPerToken_internal(team.gegoId, lastTimeRewardApplicable);
                team.lastUpdateTime = block.timestamp; 
                team.initReward = 0;
                team.rewardRate = 0;
                _teams[team.gegoId] = team;
            }
        }
        // sort
        for (uint256 i = 0; i < teamIndex; i++) {
            for (uint256 j = i + 1; j < teamIndex; j++) {
                if (captainExistArray[j].totalPower < captainExistArray[i].totalPower) {
                    Team memory c = captainExistArray[i];
                    captainExistArray[i] = captainExistArray[j];
                    captainExistArray[j] = c;
                }
            }
        }

        uint256 totalReward = totalTeamPower2Reward(totalPower, powers, rewards);

        uint256 perTeamReward = totalReward.mul(50).div(100).div(teamIndex);
        
        // Ri = R*(sqrt(si)pi))/E(sqrt(si)*pi)
        uint256 denominator = 0; // E(sqrt(si)*pi)
        for (uint256 i = 0; i < teamIndex; i++) {
            uint256 sortRank = i+1;
            Team memory team = captainExistArray[i];
            denominator = denominator.add(Math.sqrt(sortRank.mul(1000)).mul(team.totalPower));
        }
        
        for (uint256 i = 0; i < teamIndex; i++) {
            uint256 sortRank = i+1;
            Team memory team = captainExistArray[i];
            uint256 numerator = Math.sqrt(sortRank.mul(1000)).mul(team.totalPower);
            uint256 sortReward = totalReward.mul(50).div(100).mul(numerator).div(denominator);
            team.rewardPerTokenStored = rewardPerToken_internal(team.gegoId, lastTimeRewardApplicable);
            team.lastUpdateTime = block.timestamp;
            team.initReward = perTeamReward.add(sortReward);
            team.rewardRate = team.initReward.div(duration);
            _teamTotalInitReward[team.gegoId] = _teamTotalInitReward[team.gegoId].add(team.initReward);
            _teams[team.gegoId] = team;
        } 

        return totalReward;
    }

    function totalTeamPower2Reward(uint256 power, uint256[] memory powers, uint256[] memory rewards) internal pure returns (uint256 reward) {
        for (uint256 i = 0; i < powers.length; i++) {
            if (power <= powers[i]) {
                return rewards[i].mul(1e18);
            }
        }
        return rewards[rewards.length-1].mul(1e18);
    }

    function stakeGego(uint256 heroId, uint256 gegoId, uint256 stakePower, address account) external onlyImplement {
        Team memory  team = _teams[heroId];
        require(team.gegoId != 0, "no team");
        require(team.captainStatus !=0, "no captain");
        
        uint256[] storage gegoIds = _accPlayerGego[heroId][account];
        if (gegoIds.length == 0) {
            gegoIds.push(0);    
            _accGegoMapIndex[heroId][0] = 0;
        }
        gegoIds.push(gegoId);
        _accGegoMapIndex[heroId][gegoId] = gegoIds.length - 1;

        uint256 accPower = _accPowerBalances[heroId][account];
        accPower = accPower.add(stakePower);
        team.totalPower = team.totalPower.add(stakePower);
        _gegoIdPowers[gegoId] = stakePower;
        _teams[heroId] = team;
        _accPowerBalances[heroId][account] = accPower;
        _accLastStakedTime[heroId][account] = now;
    }

    function stakeDego(uint256 heroId, uint256 amount, address account) external onlyImplement {
        // update power    
        Team memory team = _teams[heroId];
        require(team.gegoId != 0, "no team");
        require(team.captainStatus != 0, "no captain");

        team.totalSupply = team.totalSupply.add(amount);
        uint256 balance = _accBalances[heroId][account];
        balance = balance.add(amount);
        _accBalances[heroId][account] = balance;

        uint256 stakePower = amount;

        uint256 powerBalance = _accPowerBalances[heroId][account];
        powerBalance = powerBalance.add(stakePower);
        _accPowerBalances[heroId][account] = powerBalance;
        team.totalPower = team.totalPower.add(stakePower);

        _accLastStakedTime[heroId][account] = now;
        _teams[heroId] = team;
    }

    // governance
    // --- Init ---
    function initialize( ) public {
        require(!_initialized, "initialize: Already initialized!");
        _governance = tx.origin;
        _initialized = true;
    }

    function setGovernance(address governance) external onlyGovernance{
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }
}
