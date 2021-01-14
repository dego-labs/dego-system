pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "../interface/IChristmasDegoDividendTeam.sol";

import "../library/Math.sol";

contract ChristmasDegoDividendTeam is IChristmasDegoDividendTeam {

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

    // uint256 [] calldata powers, uint256[] calldata rewards
    function startDivident(uint256 _lastTimeRewardApplicable, uint256 _duration, uint256 rewards) external onlyImplement returns (uint256){
        // dispatch team, computer rewardRate
        uint256 totalPower = 0;
        uint256 duration = _duration;
        uint256 lastTimeRewardApplicable = _lastTimeRewardApplicable;
        uint256 teamLen = _teamIndexes.length;
        Team[] memory captainExistArray = new Team[](teamLen);
        uint256 teamIndex = 0;
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

        uint256 totalReward = rewards;

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

    function stakeGego(uint256 heroId, uint256 gegoId, uint256 stakePower, address account) external onlyImplement {
        Team memory  team = _teams[heroId];
        require(team.gegoId != 0, "no team");
        require(team.captainStatus != 0, "no captain");
        
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
        require(team.captainStatus == 1, "no captain");

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