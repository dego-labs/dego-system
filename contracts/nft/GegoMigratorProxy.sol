pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./GegoBaseProxy.sol";
import "../interface/IGegoFactoryV1.sol";
import "../interface/IGegoToken.sol";



contract GegoMigratorProxy is GegoBaseProxy{
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    IGegoFactoryV1 public _factoryV1 = IGegoFactoryV1(0x0);
    address public _gegoV1 = address(0x0);

    bool public _hasApproval = false;

    IGegoToken.GegoV1 public _gegoV1Info;
    

    uint256 public _maxV1GegoID = 54095;

    function setMaxV1GegoId(uint256 val) public onlyGovernance{
        _maxV1GegoID =  val;
    }

    constructor(address costErc20Pool, address airdropToken, address factoryV1, address gegoV1)  
        GegoBaseProxy(costErc20Pool,airdropToken) public {
        _factoryV1 = IGegoFactoryV1(factoryV1);
        _gegoV1 = gegoV1;
    }
  
    function cost(MintParams calldata params, Cost721Asset calldata costSet1, Cost721Asset calldata costSet2 ) external returns (  uint256 mintAmount,address mintErc20 ){
        require( _factory == IGegoFactoryV2(msg.sender)," invalid factory caller" );
        require(costSet1.costErc721Origin == _gegoV1, "not gego v1");

        uint256 migratorGegoId = costSet1.costErc721Id1;

        require(migratorGegoId <= _maxV1GegoID, "not valid gego");

        uint256 degoAmount;

        _gegoV1Info.id = migratorGegoId;
        (_gegoV1Info.grade, _gegoV1Info.quality, degoAmount, _gegoV1Info.createdTime,_gegoV1Info.blockNum, _gegoV1Info.resId, _gegoV1Info.author) = _factoryV1.getGego(migratorGegoId);

        IERC721(_gegoV1).transferFrom(params.user, address(this), migratorGegoId);

        if(_hasApproval == false){ 
            IERC721(_gegoV1).setApprovalForAll(address(_factoryV1), true);
            _hasApproval = true;
        }

        IERC20 mintIErc20 = IERC20(_ruleData[params.ruleId].mintErc20);

        //uint256 balanceBefore = mintIErc20.balanceOf(address(this));
        _factoryV1.burn(migratorGegoId);
        //uint256 balanceEnd = mintIErc20.balanceOf(address(this));

        //@warning: dego team pay for it, transfer some dego to contract
        //mintAmount = balanceEnd.sub(balanceBefore);
        mintAmount = degoAmount;
        mintErc20 = _ruleData[params.ruleId].mintErc20;

        costSet2;

        super._airdrop(params.user);
    } 

    function generate( address user , uint256 ruleId) external view returns ( IGegoToken.Gego memory gego ){
        require( _factory == IGegoFactoryV2(msg.sender) ," invalid factory caller" );

        user;
        ruleId;
        gego.id = _gegoV1Info.id;
        gego.tLevel = 1;
        gego.grade = _gegoV1Info.grade;
        gego.quality = _gegoV1Info.quality;
        gego.resBaseId = _gegoV1Info.resId;
        gego.createdTime = _gegoV1Info.createdTime;
        gego.blockNum = _gegoV1Info.blockNum;
        gego.author = _gegoV1Info.author;
    } 
}
