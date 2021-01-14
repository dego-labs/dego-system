pragma solidity ^0.5.5;


import "../interface/IERC20.sol";
import "../library/SafeERC20.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../interface/IGegoToken.sol";
import "../interface/IGegoFactory.sol";
import "../library/Governance.sol";

import "../library/DegoUtil.sol";

contract GegoFactory is Governance, IGegoFactory{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct Gego {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 degoAmount;
        uint256 createdTime;
        uint256 blockNum;
        uint256 resId;
        address author;
    }

    event GegoAdded(
        uint256 indexed id,
        uint256 grade,
        uint256 quality,
        uint256 degoAmount,
        uint256 createdTime,
        uint256 blockNum,
        uint256 resId,
        address author
    );

    event GegoBurn(
        uint256 indexed id,
        uint256 degoAmount
    );

    event NFTReceived(address operator, address from, uint256 tokenId, bytes data);

    // for minters
    mapping(address => bool) public _minters;
    mapping(uint256 => Gego) public _gegoes;


    mapping(address => bool ) public _whitelist;

    uint32 public _gegoId = 0;

    uint256 public _minBurnTime = 1000*365 days;

    uint256 public _qualityBase = 10000;

    IERC20 public _dego = IERC20(0x0);

    IERC20 public _airdropToken = IERC20(0x0);

    IGegoToken public _gego = IGegoToken(0x0);

    uint256 public _maxClaimCount = 40000;
    uint256 public _currentClaimCount = 0;
    
    bool public _isClaimStart = false;
    
    mapping(address => bool) public _claimMembers;

    uint256 public _maxClaimKryptonite = 20;
    uint256 public _stakeDegoForKryptonite = 100 * (10**18);
    uint256 public _currentClaimKryptonite = 0;
    uint256 public _maxGrade = 6;
    uint256 public _maxGradeLong = 20;

    bool public _canMintToken = true;
    uint256 public _mintDegoRate = 100;

    constructor(address dego, address gego) public {
        _dego = IERC20(dego);
        _gego = IGegoToken(gego);
        _airdropToken = IERC20(dego);
    }
    

    function setMaxClaimKryptonite(uint256 value) public onlyGovernance{
        _maxClaimKryptonite =  value;
    }

    function setClaimStart(bool start) public onlyGovernance {
        _isClaimStart = start;
    }

    /**
     * @dev for set min burn time
     */
    function setMinBurnTime(uint256 minBurnTime) public onlyGovernance {
        _minBurnTime = minBurnTime;
    }

    function addMinter(address minter) public onlyGovernance {
        _minters[minter] = true;
    }

    function removeMinter(address minter) public onlyGovernance {
        _minters[minter] = false;
    }

    function addWhitelist(address member) external onlyGovernance {
        _whitelist[member] = true;
    }

    function removeWhitelist(address member) external onlyGovernance {
        _whitelist[member] = false;
    }

    /// @dev batch set quota for user admin
    /// if openTag <=0, removed 
    function setWhitelist(address[] calldata users, bool openTag)
        external
        onlyGovernance
    {
        for (uint256 i = 0; i < users.length; i++) {
            _whitelist[users[i]] = openTag;
        }
    }


    /**
     * @dev set dego contract address
     */
    function setDegoContract(address dego)  public  
        onlyGovernance{
        _dego = IERC20(dego);
    }

    /**
     * @dev set gego contract address
     */
    function setGegoContract(address gego)  public  
        onlyGovernance{
        _gego = IGegoToken(gego);
    }

    /**
     * @dev set dandy contract address
     */
    function setAirdropToken(address airdropToken)  public  
        onlyGovernance{
        _airdropToken = IERC20(airdropToken);
    }

    /**
     * @dev set isCanMintToken
     */
    function setCanMintToken(bool b)  public  
        onlyGovernance{
        _canMintToken =  b;
    }

    /**
     * @dev set maxClaimCount
     */
    function setMaxClaimCount(uint256 maxClaimCount)  public  
        onlyGovernance{
        _maxClaimCount = maxClaimCount;
    }

    function setMintDegoRate(uint256 mintDegoRate) public onlyGovernance {
        _mintDegoRate = mintDegoRate;
    }


    function getGego(uint256 tokenId)
        external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 degoAmount,
            uint256 createdTime,
            uint256 blockNum,
            uint256 resId,
            address author
        )
    {
        Gego storage gego = _gegoes[tokenId];
        require(gego.id > 0, "not exist");
        grade = gego.grade;
        quality = gego.quality;
        degoAmount = gego.degoAmount;
        createdTime = gego.createdTime;
        blockNum = gego.blockNum;
        resId = gego.resId;
        author = gego.author;
    }

    function getQualityBase() external view 
        returns (uint256 ){
        return _qualityBase;
    }



    function computerSeed() private view returns (uint256) {
        // from fomo3D
        uint256 seed = uint256(keccak256(abi.encodePacked(
            
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
            
        )));
        return seed;
    }

    function setResId(uint256 tokenId, uint256 resId) external onlyGovernance {
        require( _gegoes[tokenId].id > 0, "not exist");
        _gegoes[tokenId].resId = resId;
    }


    function getGrade(uint256 quality) public view returns (uint256){
        if( quality < _qualityBase.mul(500).div(1000)){
            return 1;
        }else if( _qualityBase.mul(500).div(1000) <= quality && quality <  _qualityBase.mul(800).div(1000)){
            return 2;
        }else if( _qualityBase.mul(800).div(1000) <= quality && quality <  _qualityBase.mul(900).div(1000)){
            return 3;
        }else if( _qualityBase.mul(900).div(1000) <= quality && quality <  _qualityBase.mul(980).div(1000)){
            return 4;
        }else if( _qualityBase.mul(980).div(1000) <= quality && quality <  _qualityBase.mul(998).div(1000)){
            return 5;
        }else{
            return 6;
        }
    }

    function airdrop(uint32 gego_id, uint256 degoAmount, uint256 grade, uint256 quality, address author) public returns( uint256){
        require(_minters[msg.sender]  , "can't mint");

        // change v6 
        if(grade == 6){
            grade = grade.sub(1);
            quality = quality.sub(_maxGradeLong);
            degoAmount = 5 * (10**18);
        }
        uint256 gegoId = doMint(gego_id, degoAmount, grade, quality, grade, author);
        return gegoId;
    }


    function claim() public returns( uint256){
        require(_isClaimStart == true, "claim not start"); 
        require(_claimMembers[msg.sender] == false, "has claim");
        require(_whitelist[msg.sender] == true, "not in whitelist");
        require(_currentClaimCount < _maxClaimCount, "claim enough"); 

        uint256 quality = 0;
        uint256 grade = 0;
        uint256 degoAmount = 0;

        uint256 seed = computerSeed();
        quality = seed%_qualityBase;
        grade = getGrade(quality);
        if(grade == _maxGrade){
            if( _currentClaimKryptonite >= _maxClaimKryptonite ){
                grade = grade.sub(1);
                quality = quality.sub(_maxGradeLong);
            }else{
                _currentClaimKryptonite = _currentClaimKryptonite.add(1);
            }
        }

        degoAmount = grade * (10**18);
      
        if(grade == _maxGrade ){
            degoAmount = _stakeDegoForKryptonite;
        }
        
        uint256 gegoId = doMint(0, degoAmount, grade, quality, grade, msg.sender);

        _claimMembers[msg.sender] = true;

        if(_canMintToken){
            _airdropToken.mint(msg.sender, degoAmount.div(_mintDegoRate)); 
        }

        _currentClaimCount =  _currentClaimCount.add(1);

        return gegoId;
    }


    /// @dev Creates a new card in the Cards contract and mints the token
    // prettier-ignore
    function doMint(uint32 gego_id, uint256 degoAmount, uint256 grade, uint256 quality, uint256 resId, address author) internal  returns (uint256) {
        require(degoAmount > 0, "must stake dego in nft");

        if(gego_id == 0){
            _gegoId++ ;
            gego_id = _gegoId;
        }else{
            if(gego_id > _gegoId){
                _gegoId =  gego_id;
            }
        }

        Gego memory gego;
        gego.id = gego_id;

        gego.blockNum = block.number;
        gego.createdTime =  block.timestamp ;
        gego.grade = grade;
        gego.quality = quality;
        gego.degoAmount = degoAmount;
        gego.author = author;
        gego.resId = resId;


        _gegoes[gego_id] = gego;

        _gego.mint(author, gego_id);

        emit GegoAdded(
            gego.id,
            gego.grade,
            gego.quality,
            gego.degoAmount,
            gego.createdTime,
            gego.blockNum,
            gego.resId,
            gego.author
        );

        return gego_id;
    }


    function burn(uint256 tokenId) external returns ( bool ) {
      
        Gego memory gego = _gegoes[tokenId];
        require(gego.id > 0, "not exist");
        require( (block.timestamp - gego.createdTime) >= _minBurnTime, "< minBurnTime"  );

        // transfer nft to contract
        _gego.safeTransferFrom(msg.sender, address(this), tokenId);
        _gego.burn(tokenId);
        _dego.safeTransfer(msg.sender, gego.degoAmount);

        // set burn flag
        emit GegoBurn(gego.id, gego.degoAmount);
        gego.id = 0;
        
        return true;
    }

    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        //only receive the _nft staff
        if(address(this) != operator) {
            //invalid from nft
            return 0;
        }
        //success
        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
