pragma solidity ^0.5.5;

import '@openzeppelin/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts/utils/Address.sol";

import "../interface/IERC20.sol";
import "../library/SafeERC20.sol";
import "../library/Governance.sol";


/// @title DegoToken Contract

contract DegoTokenAirDrop is Governance{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //events
    event Mint(address indexed to, uint256 value);

    //token base data
    uint256 internal _allGotBalances;
    mapping(address => uint256) public _gotBalances;

    //airdrop info
    uint256 public _startTime =  now;
    /// Constant token specific fields
    uint256 public _rewardRate1 = 2000;
    uint256 public _rewardRate2 = 8000;
    uint256 public _rewardDurationTime = 100 days;
    uint256 public _baseRate = 10000;
    
    mapping (address => uint256) public _whitelist;
    mapping (address => uint256) public _lastRewardTimes;

    IERC20 public _dego = IERC20(0x0);

    /**
     * CONSTRUCTOR
     *
     * @dev Initialize the Contract
    * @param dego The address to send dego.
     */
    constructor (address dego) public {
         _dego = IERC20(dego);
         _startTime = now;
    }


    /**
    * @dev have Got the balance of the specified address.
    * @param account The address to query the the gotbalance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function gotBalanceOf(address account) external  view 
    returns (uint256) 
    {
        return _gotBalances[account];
    }


    /**
    * @dev return the token total supply
    */
    function allGotBalances() external view 
    returns (uint256) 
    {
        return _allGotBalances;
    }

    
    /**
    * @dev for mint function
    * @param account The address to get the reward.
    * @param amount The amount of the reward.
    */
    function _mint(address account, uint256 amount) internal 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_whitelist[account] > 0, "must in whitelist");
        
        _allGotBalances = _allGotBalances.add(amount);      
        _gotBalances[account] = _gotBalances[account].add(amount);

        _dego.mint(account, amount);
        emit Mint(account, amount);
    }
    
    /**
    * @dev set the dego contract address
    * @param dego Set the dego
    */
   function setDego(address dego)
        external
        onlyGovernance
   {
        require(dego != address(0), "dego is zero address");
        _dego = IERC20(dego);
    }


    /**
    * @dev set the whitelist
    * @param account Set the account to whitelist
    * @param amount the amount of reward.
    */
    function setWhitelist(address account, uint256 amount)
        public
        onlyGovernance
   {
       require(account != address(0), "account is zero address");
       if(amount > 0){
           require(_whitelist[account] == 0, "account already exists");
       }
       _whitelist[account] = amount;
    }
    


    function addWhitelist(address[] calldata account,  uint256[] calldata value)
        external
        onlyGovernance
    {
        require(account.length == value.length, "wrong argument");
        for (uint256 i = 0; i < account.length; i++) {
            setWhitelist(account[i], value[i]);
        }
    }
    
    /**
    * @dev get reward
    */
   function getReward() public
   {
        uint256 reward = earned(msg.sender);
        require(reward > 0, "must > 0");
        require(reward.add(_gotBalances[msg.sender]) <= _whitelist[msg.sender], "You've got too many awards!!!");
        _mint(msg.sender, reward);
        _lastRewardTimes[msg.sender] = block.timestamp;
    }


    /**
    * @dev  Calculate and reuturn Unclaimed rewards 
    */
   function earned(address account) public view returns (uint256) 
   {
        require(_whitelist[account] > 0, "must in whitelist");

        uint256 reward = 0;
        uint256 accountTotal = _whitelist[account];
        uint256 rewardPerSecond = accountTotal.mul(_rewardRate2).div(_baseRate).div(_rewardDurationTime);
        uint256 lastRewardTime = _lastRewardTimes[account];

        // fist time get 20%
        if( lastRewardTime == 0 ){
            uint256 reward1 = accountTotal.mul(_rewardRate1).div(_baseRate);
            uint256 durationTime = block.timestamp.sub(_startTime);
            uint256 reward2 = durationTime.mul(rewardPerSecond);
            reward = reward1 + reward2;
            return reward;
        }
        
        uint256 durationTime = block.timestamp.sub(lastRewardTime);
        reward = durationTime.mul(rewardPerSecond);
        return reward;
   }
}