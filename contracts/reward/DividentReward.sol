pragma solidity ^0.5.0;

// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/ownership/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// // nego
// // import "../interface/IERC20.sol";
// import "../library/SafeERC20.sol";
// import "../library/Governance.sol";
// import "../interface/IPool.sol";
// import "../interface/IERC20.sol";
// import "../interface/IPlayerBook.sol";
// import "../interface/IGegoFactory.sol";
// import "../interface/IGegoToken.sol";

    
// contract DividentReward is IPool,Governance {
//     using SafeERC20 for IERC20;
//     using SafeMath for uint256;

//     IERC20 public _degoToken = IERC20(0x0);
//     IGegoFactory public _gegoFactory = IGegoFactory(0x0);
//     IGegoToken public _gegoToken = IGegoToken(0x0);
    
//     address public _teamWallet = 0x3D0a845C5ef9741De999FC068f70E2048A489F2b;
//     address public _rewardPool = 0xEA6dEc98e137a87F78495a8386f7A137408f7722;
//     uint256 public _oneDayRate = 50;
//     uint256 public _rate = 1000;

//     uint256 public _oneDayReward = 0;
//     uint256 public _startTime =  now + 365 days;
    
//     uint256 public _rewardRate = 0; // 1s get reward
//     uint256 public _lastUpdateTime;
//     uint256 public _rewardPerTokenStored;
//     uint256 public _punishTime = 3 days;

//     mapping(address => uint256) public _userRewardPerTokenPaid;// 
//     mapping(address => uint256) public _rewards;
//     mapping(address => uint256) public _lastStakedTime;

//     bool public _hasStart = false;
//     uint256 private _totalSupply;
//     uint256 public _totalReward;
    
//     mapping(address => uint256) public _degoBalances;
//     mapping(address => uint256[]) public _playerNego;
//     mapping(uint256 => uint256) public _negoMapIndex;
    
//     uint256 public _teamRewardRate = 500;
//     uint256 public _poolRewardRate = 1000;
//     uint256 public _baseRate = 10000;

//     event SetDividentReward(uint256 reward);
//     event StakedDego(address indexed user, uint256 amount);
//     event StakedNEGO(address indexed user, uint256 amount);
//     event WithdrawnDego(address indexed user, uint256 amount);
//     event WithdrawnNego(address indexed user, uint256 amount);
//     event RewardPaid(address indexed user, uint256 reward);
//     event NFTReceived(address operator, address from, uint256 tokenId, bytes data);

//     constructor(address dego, address nego, address negoFactory,address playerBook) public {
//         _degoToken = IERC20(dego);
//         _gegoToken = IGegoToken(nego);
//         _gegoFactory = IGegoFactory(negoFactory);
//     }

//     function() external payable {
//         uint256 value = msg.value;
//         _totalReward = _totalReward.add(value);
//     }

//     // update power or reward (add all reward)
//     modifier updateReward(address account) {
//         _rewardPerTokenStored = rewardPerToken();
//         _lastUpdateTime = lastTimeRewardApplicable();
//         if (account != address(0)) {
//             _rewards[account] = earned(account);
//             _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
//         }

//         if (lastTimeRewardApplicable() > _startTime + 1 days) {
//             _startTime = lastTimeRewardApplicable();
//             _oneDayReward = _totalReward.mul(_oneDayRate).div(_rate);
//             _rewardRate = _oneDayReward.div(1 days); 
//         }
//         _;
//     }

//     // for update reward
//     function notifyUpdateRewardRate() external {
//         _rewardPerTokenStored = rewardPerToken();
//         _lastUpdateTime = lastTimeRewardApplicable();
//         if (lastTimeRewardApplicable() > _startTime + 1 days) {
//             _startTime = lastTimeRewardApplicable();
//             _oneDayReward = _totalReward.mul(_oneDayRate).div(_rate);
//             _rewardRate = _oneDayReward.div(1 days); 
//         }
//     }

//     /* Fee collection for any other token */
//     function seizeErc20(IERC20 token, uint256 amount) external 
//     {
//         require(token != _degoToken, "dego reward");
//         token.safeTransfer(_governance, amount);
//     }
    
//     /* Fee collection for any other token */
//     function seizeErc721(IERC721 token, uint256 tokenId) external 
//     {
//         require(token != _gegoToken, "nego stake");
//         token.safeTransferFrom(address(this), _governance, tokenId);
//     }

//     function lastTimeRewardApplicable() public view returns (uint256) {
//         return block.timestamp;
//     }

//     function rewardPerToken() public view returns (uint256) {
//         if (totalSupply() == 0) {
//             return _rewardPerTokenStored;
//         }
//         return
//             _rewardPerTokenStored.add(
//                 lastTimeRewardApplicable()
//                     .sub(_lastUpdateTime)
//                     .mul(_rewardRate)
//                     .mul(1e18)
//                     .div(totalSupply())
//             );
//     }

//     function earned(address account) public view returns (uint256) {
//         return
//             degoBalanceOf(account)
//                 .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
//                 .div(1e18)
//                 .add(_rewards[account]);
//     }

//     // stake Dego visibility is public as overriding LPTokenWrapper's stake() function
//     function stakeDego(uint256 amount, string memory affCode)
//         public
//         updateReward(msg.sender)
//         checkStart
//     {
//         require(amount > 0, "Cannot stake 0");
//         _totalSupply = _totalSupply.add(amount);
//         _degoBalances[msg.sender] = _degoBalances[msg.sender].add(amount);
//         _degoToken.safeTransferFrom(msg.sender, address(this), amount);
        
//         _lastStakedTime[msg.sender] = now;
//         emit StakedDego(msg.sender, amount);
//     }

//     // stake NEGO visibility is public as overriding LPTokenWrapper's stake() function
//     function stakeNego(uint256 _gegoId, string memory affCode)
//         public
//         updateReward(msg.sender)
//         checkStart
//     {
//         uint256 dividendWeight;
//         uint256 degoAmount;
//         uint256 createdTime;
//         bytes memory metadata;
//         (dividendWeight, degoAmount, createdTime, metadata) = _gegoFactory.getGego(_gegoId);

//         require(degoAmount > 0,"the nego not dego");

//         uint256[] storage negoId = _playerNego[msg.sender];
//         if (negoId.length == 0) {
//             negoId.push(0);    
//             _negoMapIndex[0] = 0;
//         }
//         negoId.push(_gegoId);
//         _negoMapIndex[_gegoId] = negoId.length - 1;
        
//         // for in amount
//         uint256 negoBase = _gegoFactory.getDividendBase();
//         uint256 addDegoAmount = degoAmount.mul(dividendWeight.add(1).div(negoBase));

//         _degoBalances[msg.sender] = _degoBalances[msg.sender].add(addDegoAmount);
//         _totalSupply = _totalSupply.add(addDegoAmount);

//         _gegoToken.safeTransferFrom(msg.sender, address(this), _gegoId);

//         _lastStakedTime[msg.sender] = now;
//         emit StakedNEGO(msg.sender, _gegoId);
//     }
    
//     function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
//         if(_hasStart == false) {
//             return 0;
//         }

//         emit NFTReceived(operator, from, tokenId, data);
//         return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
//     }

//     function withdrawDego(uint256 amount)
//         public
//         updateReward(msg.sender)
//         checkStart
//     {
//         require(now > (_lastStakedTime[msg.sender]) + _punishTime, "not 3 days");
//         require(amount > 0, "Cannot withdraw 0");
//         _totalSupply = _totalSupply.sub(amount);
//         _degoBalances[msg.sender] = _degoBalances[msg.sender].sub(amount);
//         _degoToken.safeTransfer(msg.sender, amount);
//         emit WithdrawnDego(msg.sender, amount);
//     }

//     function withdrawNego(uint256 _gegoId)
//         public
//         updateReward(msg.sender)
//         checkStart
//     {
//         require(now > (_lastStakedTime[msg.sender]) + _punishTime, "not 3 days");
//         require(_gegoId > 0, "the negoId error");
//         uint256 dividendWeight;
//         uint256 degoAmount;
//         uint256 createdTime;
//         bytes memory metadata;
//         (dividendWeight, degoAmount, createdTime, metadata) = _gegoFactory.getNego(_gegoId);
        
//         uint256[] memory negoId = _playerNego[msg.sender];
        
//         uint256 negoArrayLength = negoId.length-1;
//         uint256 tailId = negoId[negoArrayLength];
//         uint256 negoIndex = _negoMapIndex[_gegoId];
//         _playerNego[msg.sender][negoIndex] = tailId;
//         _playerNego[msg.sender][negoArrayLength] = 0;
//         _playerNego[msg.sender].length --;
//         _negoMapIndex[tailId] = negoIndex;
//         _negoMapIndex[_gegoId] = 0;
        
//         // for in amount
//         uint256 negoBase = _gegoFactory.getDividendBase();
//         uint256 subDegoAmount = degoAmount.mul(dividendWeight.add(1).div(negoBase));
//         _totalSupply = _totalSupply.sub(subDegoAmount);
//         _degoBalances[msg.sender] = _degoBalances[msg.sender].sub(subDegoAmount);
//         _gegoToken.safeTransferFrom(address(this), msg.sender, _gegoId);
//         emit WithdrawnNego(msg.sender, _gegoId);
//     }

//     function withdraw()
//         public
//         checkStart
//     {
//         uint256 degoBalance = degoBalanceOf(msg.sender);
//         if (degoBalance > 0) {
//             withdrawDego(degoBalance);
//         }

//         uint256[] memory negoId = _playerNego[msg.sender];
//         for (uint8 index = 1; index < negoId.length; index++) {
//             if (negoId[index] > 0) {
//                 withdrawNego(negoId[index]);
//             }
//         }
//     }

//     function exit() external {
//         withdraw();
//         getReward();
//     }

//     function getReward() 
//         public 
//         updateReward(msg.sender) 
//         checkStart 
//     {
        
//         // require(now > _startTime + 1 days, "not 24 hours");

//         uint256 reward = earned(msg.sender);
//         if (reward > 0) {
//             _rewards[msg.sender] = 0;
            
//             uint256 teamReward = reward.mul(_teamRewardRate).div(_baseRate);
//             if(teamReward>0){
//                 msg.sender.transfer(teamReward);
//             }
//             // todo:
//             // uint256 leftReward = reward.sub(fee).sub(teamReward);
//             // if(leftReward>0){
//             //     msg.sender.transfer(leftReward);
//             // }
//             // _totalReward = _totalReward.sub(reward);
//             // emit RewardPaid(msg.sender, leftReward);
//         }
//     }
    
//     modifier checkStart() {
//         require(block.timestamp > _startTime, "not start");
//         _;
//     }

//     // set fix time to start reward
//     function startDividentReward(uint256 startTime)
//         external
//         onlyGovernance
//         updateReward(address(0))
//     {
//         require(_hasStart == false, "has started");
//         _hasStart = true;
        
//         _startTime = startTime;

//         _oneDayReward = _totalReward.mul(_oneDayRate).div(_rate);
//         _rewardRate = _oneDayReward.div(1 days); 

//         _lastUpdateTime = _startTime;

//         emit SetDividentReward(_oneDayReward);
//     }
  

//     function setTeamRewardRate( uint256 teamRewardRate ) public onlyGovernance {
//         _teamRewardRate = teamRewardRate;
//     }

//     function setPoolRewardRate( uint256  poolRewardRate ) public onlyGovernance{
//         _poolRewardRate = poolRewardRate;
//     }

//     function degoBalanceOf(address account) public view returns (uint256) {
//         return _degoBalances[account];
//     }

//     function totalSupply()  public view returns (uint256) {
//         return _totalSupply;
//     }

//     function balanceOf(address account) public view returns (uint256) {
//         uint256 negoBalance = 0;
//         uint256[] memory negoId = _playerNego[account];
//         for (uint8 index = 1; index < negoId.length; index++) {
//             if (negoId[index] > 0) {
//                 uint256 dividendWeight;
//                 uint256 degoAmount;
//                 uint256 createdTime;
//                 bytes memory metadata;
//                 (dividendWeight, degoAmount, createdTime, metadata) = _gegoFactory.getNego(negoId[index]); 
//                 negoBalance = negoBalance.add(degoAmount);
//             }
//         }
//         return _degoBalances[account].add(negoBalance);
//     }
// }