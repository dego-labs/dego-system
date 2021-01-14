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