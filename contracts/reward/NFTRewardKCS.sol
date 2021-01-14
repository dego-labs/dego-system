pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// gego

import "../library/SafeERC20.sol";
import "../library/Governance.sol";
import "../interface/IPool.sol";
import "../interface/IERC20.sol";
import "../interface/IGegoFactoryV2.sol";
import "../interface/IGegoToken.sol";

    
contract NFTRewardKCS is IPool,Governance {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _rewardToken = IERC20(0x0);
    IGegoFactoryV2 public _gegoFactory = IGegoFactoryV2(0x0);
    IGegoToken public _gegoToken = IGegoToken(0x0);

    uint256 public _startTime1 =  now + 365 days;
    uint256 public FINISHDURATION1 = 7 days;
    uint256 public _stageFinish1 = 0;
    uint256 public _rewardRate1 = 0;
    bool public _hasStart1 = false;
    uint256 public _startTime2 =  now + 365 days;
    uint256 public FINISHDURATION2 =  7 days;
    uint256 public _stageFinish2 = 0;
    uint256 public _rewardRate2 = 0;
    bool public _hasStart2 = false;
    uint256 public _initReward = 0;
    uint256 public _ruleId = 0;
    uint256 public _nftType = 0;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerTokenStored;
    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    
    uint256 public _fixRateBase = 100000;
    
    uint256 public _totalWeight;
    mapping(address => uint256) public _weightBalances;

    mapping(address => uint256[]) public _playerGego;
    mapping(uint256 => uint256) public _gegoMapIndex;

    event RewardAdded(uint256 reward);
    event StakedGEGO(address indexed user, uint256 amount);
    event WithdrawnGego(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event SetStartTime(uint256 startTime);
    event FinishReward(uint256 reward);
    event StartReward(uint256 reward);

    modifier updateReward(address account) {
        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    modifier checkOnRewardTime() {
        require((block.timestamp > _startTime1 && block.timestamp <= _stageFinish1)||(block.timestamp > _startTime2 && block.timestamp <= _stageFinish2), "not on stage");
        _;
    }

    constructor(address rewardToken, address gegoToken, address gegoFactory, uint256 ruleId, uint256 nftType) public {
        _rewardToken = IERC20(rewardToken);
        _gegoToken = IGegoToken(gegoToken);
        _gegoFactory = IGegoFactoryV2(gegoFactory);
        _ruleId = ruleId;
        _nftType = nftType;
    }

    function totalSupply()  public view returns (uint256) {
        return _totalWeight;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _weightBalances[account];
    }

    /* Fee collection for any other token */
    function seize(IERC20 token, uint256 amount) external {
        require(token != _rewardToken, "reward");
        token.safeTransfer(_governance, amount);
    }
    
    /* Fee collection for any other token */
    function seizeErc721(IERC721 token, uint256 tokenId) external {
        require(token != _gegoToken, "reward");
        token.safeTransferFrom(address(this), _governance, tokenId);
    }

    // fix
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return _rewardPerTokenStored;
        }
        if (_lastUpdateTime <= _stageFinish1) {
            return
                _rewardPerTokenStored.add(
                    lastTimeRewardApplicable()
                        .sub(_lastUpdateTime)
                        .mul(_rewardRate1)
                        .mul(1e18)
                        .div(totalSupply())
                );
        }else{
            return
                _rewardPerTokenStored.add(
                    lastTimeRewardApplicable()
                        .sub(_lastUpdateTime)
                        .mul(_rewardRate2)
                        .mul(1e18)
                        .div(totalSupply())
                );
        }
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }

    
    //the grade is a number between 1-6
    //the quality is a number between 1-10000
    /*
    1   quality	1.1+ 0.1*quality/5000
    2	quality	1.2+ 0.1*(quality-5000)/3000
    3	quality	1.3+ 0.1*(quality-8000/1000
    4	quality	1.4+ 0.2*(quality-9000)/800
    5	quality	1.6+ 0.2*(quality-9800)/180
    6	quality	1.8+ 0.2*(quality-9980)/20
    */

    function getFixRate(uint256 grade,uint256 quality) public pure returns (uint256){

        require(grade > 0 && grade <7, "the gego not token");

        uint256 unfold = 0;
        if( grade == 1 ){
            unfold = quality*10000/5000;
            return unfold.add(110000);
        }else if( grade == 2){
            unfold = quality.sub(5000)*10000/3000;
            return unfold.add(120000);
        }else if( grade == 3){
            unfold = quality.sub(8000)*10000/1000;
           return unfold.add(130000);
        }else if( grade == 4){
            unfold = quality.sub(9000)*20000/800;
           return unfold.add(140000);
        }else if( grade == 5){
            unfold = quality.sub(9800)*20000/180;
            return unfold.add(160000);
        }else{
            unfold = quality.sub(9980)*20000/20;
            return unfold.add(180000);
        }
    }

    function getStakeInfo( uint256 gegoId ) public view returns ( uint256 stakeRate, uint256 amount,uint256 ruleId,uint256 nftType){

        uint256 grade;
        uint256 quality; 
        (grade,quality,amount, , ,ruleId, nftType, , , , ) = _gegoFactory.getGego(gegoId);
        require(amount > 0,"the gego not token");
        stakeRate = getFixRate(grade,quality);
    }

    // stake GEGO 
    function stakeGego(uint256 gegoId)
        public
        updateReward(msg.sender)
        checkOnRewardTime
    {
        uint256[] storage gegoIds = _playerGego[msg.sender];
        if (gegoIds.length == 0) {
            gegoIds.push(0);    
            _gegoMapIndex[0] = 0;
        }
        gegoIds.push(gegoId);
        _gegoMapIndex[gegoId] = gegoIds.length - 1;

        uint256 stakeRate;
        uint256 ercAmount;
        uint256 ruleId;
        uint256 nftType;
        (stakeRate, ercAmount, ruleId, nftType) = getStakeInfo(gegoId);
        
        require(ruleId == _ruleId, "Not conforming to the rules");
        require(nftType == _nftType, "Not conforming to the rules");

        if(ercAmount > 0){
            uint256 stakeWeight = stakeRate.mul(ercAmount).div(_fixRateBase);
            _weightBalances[msg.sender] = _weightBalances[msg.sender].add(stakeWeight);
            _totalWeight = _totalWeight.add(stakeWeight);
        }

        _gegoToken.safeTransferFrom(msg.sender, address(this), gegoId);

        emit StakedGEGO(msg.sender, gegoId);
        
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        // if(_hasStart1 == false && _hasStart2 == false) {
        //     return 0;
        // }

        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function withdrawGego(uint256 gegoId)
        public
        updateReward(msg.sender)
    {
        require(gegoId > 0, "the gegoId error");
        
        uint256[] memory gegoIds = _playerGego[msg.sender];
        uint256 gegoIndex = _gegoMapIndex[gegoId];
        
        require(gegoIds[gegoIndex] == gegoId, "not gegoId owner");

        uint256 gegoArrayLength = gegoIds.length-1;
        uint256 tailId = gegoIds[gegoArrayLength];

        _playerGego[msg.sender][gegoIndex] = tailId;
        _playerGego[msg.sender][gegoArrayLength] = 0;
        _playerGego[msg.sender].length--;
        _gegoMapIndex[tailId] = gegoIndex;
        _gegoMapIndex[gegoId] = 0;

        uint256 stakeRate;
        uint256 ercAmount;
        (stakeRate, ercAmount,,) = getStakeInfo(gegoId);
        uint256 stakeWeight = stakeRate.mul(ercAmount).div(_fixRateBase);
        _weightBalances[msg.sender] = _weightBalances[msg.sender].sub(stakeWeight);
        _totalWeight = _totalWeight.sub(stakeWeight);
        
        _gegoToken.safeTransferFrom(address(this), msg.sender, gegoId);

        emit WithdrawnGego(msg.sender, gegoId);
    }

    function withdraw()
        public
    {
        uint256[] memory gegoId = _playerGego[msg.sender];
        for (uint8 index = 1; index < gegoId.length; index++) {
            if (gegoId[index] > 0) {
                withdrawGego(gegoId[index]);
            }
        }
    }

    function getPlayerIds( address account ) public view returns( uint256[] memory gegoId )
    {
        gegoId = _playerGego[account];
    }

    function exit() external {
        withdraw();
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _rewards[msg.sender] = 0;
            _rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function lastTimeRewardApplicable() private view returns (uint256) {
        if (block.timestamp <= _stageFinish1) {
            return Math.min(block.timestamp, _stageFinish1);
        } else if ( _stageFinish1 < block.timestamp && block.timestamp <= _startTime2) {
            return _stageFinish1;
        } else {
            return Math.min(block.timestamp, _stageFinish2);
        }
    }
    
    
    //for extra reward
    function notifyRewardAmount(uint256 reward,uint256 duration, uint256 stage)
        external
        onlyGovernance
        updateReward(address(0))
    {
        if (stage == 1) {
            require(_hasStart1 == false, "stage1 has started");
            FINISHDURATION1 = duration;
        }else{
            require(_hasStart2 == false, "stage2 has started");
            FINISHDURATION2 = duration;
        }
        // uint256 balanceBefore = _rewardToken.balanceOf(address(this));
        // _rewardToken.safeTransferFrom(msg.sender, address(this), reward);
        // uint256 balanceEnd = _rewardToken.balanceOf(address(this));
        //_initReward = _initReward.add(balanceEnd.sub(balanceBefore));
        _initReward = reward; //balanceEnd.sub(balanceBefore);

        emit RewardAdded(_initReward);
    }


    // set fix time to start reward
    function startNFTReward(uint256 startTime, uint256 stage)
        external
        onlyGovernance
        updateReward(address(0))
    {
        if (stage == 1) {
            require(_hasStart1 == false, "stage1 has started");
            _hasStart1 = true;
            _startTime1 = startTime;    
            _stageFinish1 = startTime.add(FINISHDURATION1);
            _rewardRate1 = _initReward.div(FINISHDURATION1);
        } else {
            require(_hasStart2 == false, "stage2 has started");
            _hasStart2 = true;
            _startTime2 = startTime;    
            _stageFinish2 = startTime.add(FINISHDURATION2);
            _rewardRate2 = _initReward.div(FINISHDURATION2);
        }
        
        _lastUpdateTime = startTime;
        emit SetStartTime(startTime);
    }

    function setRuleId( uint256  ruleId) public onlyGovernance {
        _ruleId = ruleId;
    }

    function setNftType( uint256  nftType) public onlyGovernance {
        _nftType = nftType;
    }
}