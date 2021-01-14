pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../library/Math.sol";
import "./Constants.sol";

import "../library/ReentrancyGuard.sol";

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