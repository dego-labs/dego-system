pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../interface/IGegoFactoryV2.sol";
import "../interface/IGegoToken.sol";
import "../interface/IPlayerBook.sol";

import "../library/SafeERC20.sol";
import "../library/Math.sol";

import "../interface/IDegoDividendTeam.sol";
import "../library/ReentrancyGuard.sol";

contract DegoDividend is IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bool private _initialized; // Flag of initialize data
    address public _governance;
    address public _playerBook = address(0x0);

    IGegoFactoryV2 public _gegoFactoryV2 = IGegoFactoryV2(0x0);
    IGegoToken public _gegoToken = IGegoToken(0x0);
    IGegoToken public _gegoHeroToken = IGegoToken(0x0);
    IERC20 public _dego = IERC20(0x0);

    IDegoDividendTeam public _teamImpl;

    bool public _hasStart = false;
    uint256 public _duration = 7 days;
    uint256 public _startTime =  now + 365 days;
    uint256 public _periodFinish = 0;
    uint256 public _poolSurplusReward = 0;
    uint256 public _punishTime = 3 days;
    uint256 public _poolRewardRate = 10000;
    uint256 public _heroRewardRate = 20000;
    uint256 public _baseRate = 100000;
    address public _teamWallet = 0x3D0a845C5ef9741De999FC068f70E2048A489F2b;
    address public _rewardPool = 0xEA6dEc98e137a87F78495a8386f7A137408f7722;
    mapping (uint256 => bool) public _heros;
    mapping(uint256 => Rule) public _rules;
    
    uint256 public _powerFactorRate = 100000;
    
    uint256 public _cycleTimes = 0;

    uint256[] public teamPowerConfig;
    uint256[] public teamRewardConfig;
    
    struct Erc20RewardPool {
        bool isExist;
        bool isSupport;
        uint256 periodFinish;
    }

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
        // stakeDego 11
        // stakeGego 12
    // withdraw -> 2
        // withdrawDego 21
        // withdrawGego 22
    event evenStakeOrWithdraw(address user, uint256 heroId, uint256 gegoIdOrAmount, uint256 stakeOrWithdraw);
    event evenSetHero(uint256 gegoId, bool tag);
    event evenSetGegoRule(uint256 ruleId,address erc20,uint256 priceRate);
    event evenSetTeamPowerRewardConfig(uint256 index,uint256 num);
    event evenSetPowerFactorRate(uint256 powerFactorRate);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
   
    modifier checkHero(uint256 gegoId) {
        require(_heros[gegoId], "is not hero");
        _; 
    }

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    modifier checkNextEpoch {
        if (block.timestamp >= _periodFinish) {
            uint256 totalReward = _teamImpl.startNextEpoch(lastTimeRewardApplicable(), _duration,teamPowerConfig,teamRewardConfig,_cycleTimes);
            require(_poolSurplusReward >= totalReward, "poolSurplusReward is not enough");
            _poolSurplusReward = _poolSurplusReward.sub(totalReward);
            _periodFinish = block.timestamp.add(_duration);
            _cycleTimes = _cycleTimes+1;
            emit evenStartNewEpoch(totalReward);
        }
        _;
    }

    modifier updateReward(uint256 heroId, address account) {
        IDegoDividendTeam.Team memory team = _teamImpl.getTeams(heroId);
        team.rewardPerTokenStored = rewardPerToken(heroId);
        team.lastUpdateTime = lastTimeRewardApplicable();
        _teamImpl.setTeams(heroId,team);

        if (account != address(0)) {
            uint256 gotReward  = earned(heroId, account);
            uint256 userRewardPerTokenPaid = team.rewardPerTokenStored;
            _teamImpl.setAccRewards(heroId,account,gotReward);
            _teamImpl.setAccUserRewardPerTokenPaid(heroId,account,userRewardPerTokenPaid);
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp > _startTime, "not start");
        _;
    }

    // create team
    function stakeHero(uint256 gegoId, string memory affCode) public 
        checkHero(gegoId)
        updateReward(gegoId, msg.sender) 
        checkStart
        checkNextEpoch
        nonReentrant
    {
        require(gegoId > 0, "the gegoId error");
        IDegoDividendTeam.Team memory team = _teamImpl.getTeams(gegoId);
        require(team.captainStatus != 1, "have in team");

        _gegoHeroToken.safeTransferFrom(msg.sender, address(this), gegoId);
        // create team
        if (team.captainStatus == 0) {
            _teamImpl.setTeamIndexes(gegoId);
            team.gegoId = gegoId;
        }
        team.captainStatus = 1;
        team.captain = msg.sender;
        if (team.totalPower == 0){
            team.totalPower = 1;
        }
        _teamImpl.setTeams(gegoId,team);

        if (!IPlayerBook(_playerBook).hasRefer(msg.sender)) {
            IPlayerBook(_playerBook).bindRefer(msg.sender, affCode);
        }
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
        IDegoDividendTeam.Team memory team = _teamImpl.getTeams(gegoId);
        require(team.captainStatus == 1, "not in team");
        require(team.captain == msg.sender, "the gego not owner captain");
        team.captainStatus = 2;

        _gegoHeroToken.safeTransferFrom(address(this), team.captain, gegoId);
        _teamImpl.setTeams(gegoId, team);
        emit evenStakeOrWithdrawHero(msg.sender, gegoId, 2);
    }

    // join team
    function stakeGego(uint256 _heroId, uint256 _gegoId, string memory affCode)  public 
        updateReward(_heroId, msg.sender) 
        checkStart 
        checkNextEpoch
        nonReentrant
    {
        uint256 heroId = _heroId;
        uint256 gegoId = _gegoId;
        _gegoToken.safeTransferFrom(msg.sender, address(this), gegoId);

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
        amount = amount.mul(rule.priceRate).div(_baseRate);
        require(amount != 0, "Not conforming to the rules");
        uint256 stakePower = stakeRate.mul(amount).div(_baseRate);

        _teamImpl.stakeGego(heroId, gegoId, stakePower, msg.sender);

        if (!IPlayerBook(_playerBook).hasRefer(msg.sender)) {
            IPlayerBook(_playerBook).bindRefer(msg.sender, affCode);
        }
        emit evenStakeOrWithdraw(msg.sender, heroId, gegoId, 12);

    }

    function stakeDego(uint256 heroId, uint256 amount, string memory affCode) public 
        updateReward(heroId, msg.sender) 
        checkStart
        checkNextEpoch 
        nonReentrant   
    {   
        uint256 balanceBefore = _dego.balanceOf(address(this));
        _dego.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceEnd = _dego.balanceOf(address(this));
        
        uint256 finalAmount = balanceEnd.sub(balanceBefore);
        require(finalAmount > 0, "amount is error");

        _teamImpl.stakeDego(heroId, finalAmount, msg.sender);

        if (!IPlayerBook(_playerBook).hasRefer(msg.sender)) {
            IPlayerBook(_playerBook).bindRefer(msg.sender, affCode);
        }

        emit evenStakeOrWithdraw(msg.sender, heroId, finalAmount, 11);
    }

    function getReward(uint256 heroId) external  
        updateReward(heroId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        uint256 reward = earned(heroId, msg.sender);
        if (reward > 0) {
            IDegoDividendTeam.Team memory team = _teamImpl.getTeams(heroId);
            _teamImpl.setAccRewards(heroId,msg.sender,0);
            
            uint256 fee = IPlayerBook(_playerBook).settleReward(msg.sender, reward);
            if(fee > 0){
                _dego.safeTransfer(_playerBook, fee);
            }
            uint256 leftReward = reward.sub(fee);
            // 10% pool
            uint256 accLastStakedTime = _teamImpl.getAccLastStakedTime(heroId,msg.sender);
            if(now  < accLastStakedTime.add(_punishTime) ){
                uint256 poolReward = leftReward.mul(_poolRewardRate).div(_baseRate);
                _dego.safeTransfer(_rewardPool, poolReward);
                leftReward = leftReward.sub(poolReward);
            }
            // 20% hero
            uint256 heroReward = leftReward.mul(_heroRewardRate).div(_baseRate);
            if (team.captainStatus == 1) {
                _dego.safeTransfer(team.captain, heroReward);
                team.captainHadReward = team.captainHadReward.add(heroReward);
            } else {
                _dego.safeTransfer(_teamWallet, heroReward);
            }
            leftReward = leftReward.sub(heroReward);
            
            // reward
            _teamImpl.setAccTotalRewards(heroId, msg.sender, leftReward);
            _dego.safeTransfer(msg.sender, leftReward);
            _teamImpl.setTeams(heroId,team);

            emit evenRewardPaid(msg.sender, leftReward);
            
        }
    }

    function withdrawDego(uint256 heroId, uint256 amount) public  
        updateReward(heroId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        // update power  
        require(amount > 0, "the amount error");
        
        IDegoDividendTeam.Team memory team = _teamImpl.getTeams(heroId);
       
        uint256 userBal = _teamImpl.getAccBalances(heroId,msg.sender);
        if (amount > userBal) {
            amount = userBal;
        }
        team.totalSupply = team.totalSupply.sub(amount);
        userBal = userBal.sub(amount);
        _teamImpl.setAccBalances(heroId,msg.sender,userBal);

        uint256 withdrawPower = amount;
        uint256 powerBalance  = _teamImpl.getAccPowerBalances(heroId,msg.sender);
        powerBalance = powerBalance.sub(withdrawPower);
        _teamImpl.setAccPowerBalances(heroId,msg.sender,powerBalance);
        team.totalPower = team.totalPower.sub(withdrawPower);
        _teamImpl.setTeams(heroId,team);

        _dego.safeTransfer(msg.sender, amount);

        emit evenStakeOrWithdraw(msg.sender, heroId, amount, 21);
    }

    function withdrawGego(uint256 heroId, uint256 gegoId) public
        updateReward(heroId, msg.sender) 
        checkNextEpoch
        nonReentrant
    {
        // update power  
        require(gegoId > 0, "the gegoId error");
        IDegoDividendTeam.Team memory team = _teamImpl.getTeams(heroId);
        require(team.gegoId != 0, "no team");

        uint256[] memory gegoIds = _teamImpl.getAccPlayerGego(heroId, msg.sender);

        uint256 gegoIndex = _teamImpl.getAccGegoMapIndex(heroId, gegoId);
        
        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        _gegoToken.safeTransferFrom(address(this), msg.sender, gegoId);
        
        _teamImpl.deleteAccPlayerGego(heroId, msg.sender, gegoId);

        uint256 withDrawPower = _teamImpl.getGegoIdPowers(gegoId);
        uint256 accPower = _teamImpl.getAccPowerBalances(heroId, msg.sender);
        accPower = accPower.sub(withDrawPower);
        team.totalPower = team.totalPower.sub(withDrawPower);
        _teamImpl.setTeams(heroId, team);
        _teamImpl.setAccPowerBalances(heroId, msg.sender, accPower);

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
        return unfold.mul(_powerFactorRate).div(_baseRate); 
    }

    function getStakeGegoInfo( uint256 gegoId ) public view returns ( uint256 stakeRate, uint256 amount,uint256 ruleId,uint256 nftType){

        uint256 grade;
        uint256 quality; 
        (grade,quality,amount, , ,ruleId, nftType, , , , ) = _gegoFactoryV2.getGego(gegoId);
        require(amount > 0,"the gego not token");
        stakeRate = getFixRate(grade,quality);
    }

    function totalTeamPower2Reward(uint256 power) internal view returns (uint256 reward){
        for (uint256 i =0;i< teamPowerConfig.length;i++) {
            if (power <= teamPowerConfig[i]) {
                return teamRewardConfig[i].mul(1e18);
            }
        }
        return teamRewardConfig[teamRewardConfig.length-1].mul(1e18);
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return Math.min(block.timestamp, _periodFinish);
    }

    function rewardPerToken(uint256 heroId) internal view returns (uint256) {
        return _teamImpl.rewardPerToken(heroId,lastTimeRewardApplicable());
    }

    function earned(uint256 heroId, address account) public view returns (uint256) {
        return _teamImpl.earned(heroId,account,lastTimeRewardApplicable());
    }

    // governance
    // --- Init ---
    function initialize(
        address dego, 
        address gegov1, 
        address gegov2,
        address teamWallet,
        address rewardPool,
        address gegoFactoryV2,
        address playerBook,
        address teamImpl
    ) public {
        require(!_initialized, "initialize: Already initialized!");
        _governance = tx.origin;
        _dego = IERC20(dego);
        _poolSurplusReward = 0;
        _gegoHeroToken = IGegoToken(gegov1);
        _gegoToken = IGegoToken(gegov2);
        _gegoFactoryV2 = IGegoFactoryV2(gegoFactoryV2);
        _playerBook = playerBook;
        _teamWallet = teamWallet;
        _rewardPool = rewardPool;
        _hasStart = false;
        _duration = 10 days;
        _punishTime = 7 days;
        _startTime =  now + 365 days;
        _periodFinish = 0;
        _poolRewardRate = 10000;
        _heroRewardRate = 20000;
        _baseRate = 100000;
        _powerFactorRate = 100000;
        teamPowerConfig  = [100000000000000000000000, 500000000000000000000000, 1000000000000000000000000, 2000000000000000000000000];
        teamRewardConfig = [3000, 10000, 10000, 16000, 16000];
        _teamImpl = IDegoDividendTeam(teamImpl);
        _cycleTimes = 0;
        initReentrancyStatus();
        
        _initialized = true;
    }

    //for reward
    function notifyMintAmount(uint256 reward)
        external
        onlyGovernance
    {
        uint256 balanceBefore = _dego.balanceOf(address(this));
        _dego.safeTransferFrom(msg.sender, address(this), reward);
        uint256 balanceEnd = _dego.balanceOf(address(this));
        _poolSurplusReward = _poolSurplusReward.add(balanceEnd.sub(balanceBefore));
        emit evenRewardAdded(_poolSurplusReward);
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
        _startTime = startTime;
        _periodFinish = _startTime.add(_duration);
        emit evenSetStart(startTime);
    }

    function setHero(uint256 gegoId, bool tag) external onlyGovernance {
        _heros[gegoId] = tag;
        emit evenSetHero(gegoId,tag);
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

    function setTeamPowerOrReward(uint256 index,uint256 num,uint256 _type) external onlyGovernance {
        // power 0 reward 1
        if (_type ==0){
            require(index < teamPowerConfig.length);
            teamPowerConfig[index] = num;
        }else if (_type ==1){
            require(index < teamRewardConfig.length);
            teamRewardConfig[index] = num;
        }
        emit evenSetTeamPowerRewardConfig(index,num);
    }

    function setPowerFactorRate (uint256 powerFactorRate) external onlyGovernance {
        _powerFactorRate = powerFactorRate;
        emit evenSetPowerFactorRate(powerFactorRate);
    }

    /* Fee collection for any other token */
    function seize(IERC20 token, uint256 amount) external {
        require(token != _dego, "reward");
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