

pragma solidity ^0.5.5;

import "../interface/IGegoFactoryV2.sol";
import "../interface/IGegoToken.sol";
import "../library/SafeERC20.sol";
import "../interface/IChristmasDegoDividendTeam.sol";

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
