pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./GegoBaseProxy.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract GegoTLevelUpProxy is GegoBaseProxy{
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _gegoV2 = address(0x0);
    bool public _hasApproval = false;
    
    IGegoToken.Gego private  _gego1;
    IGegoToken.Gego private  _gego2;

    constructor(address costErc20Pool, address gegoV2, address airdropToken) 
        GegoBaseProxy(costErc20Pool,airdropToken) public {
            _gegoV2 = gegoV2;
    }


    /*
    // struct Cost721Asset{
    //     uint256 costErc721Id1;
    //     uint256 costErc721Id2;
    //     uint256 costErc721Id3;
    //     address costErc721Origin;
    // }

    // struct MintParams{
    //     address user;
    //     uint256 amount;
    //     uint256 ruleId;
    // }
    */

    function cost( MintParams calldata params, Cost721Asset calldata costSet1, Cost721Asset calldata costSet2 ) external returns (  uint256 mintAmount,address mintErc20 ){
        
        costSet2;

        require( _factory == IGegoFactoryV2(msg.sender)," invalid factory caller" );
        require( _ruleData[params.ruleId].costErc20 != address(0x0), "invalid costErc20 rule !");

        uint256 costErc20Amount = _ruleData[params.ruleId].costErc20Amount;
        if(costErc20Amount > 0){
            IERC20 costErc20 = IERC20(_ruleData[params.ruleId].costErc20);
            costErc20.safeTransferFrom(params.user, _costErc20Pool, costErc20Amount);
        }

        require( _gegoV2 == costSet1.costErc721Origin ,"invalid mint origin1 address!" );
      
        IERC721 gegoV2 = IERC721(_gegoV2);

        gegoV2.transferFrom(params.user, address(this), costSet1.costErc721Id1);
        gegoV2.transferFrom(params.user, address(this), costSet1.costErc721Id2);

        if(_hasApproval == false){
            gegoV2.setApprovalForAll(address(_factory), true);
            gegoV2.setApprovalForAll(address(_factory), true);
            _hasApproval = true;
        }

        _gego1 = _factory.getGegoStruct(costSet1.costErc721Id1);
        _gego2 = _factory.getGegoStruct(costSet1.costErc721Id2);

        IERC20 mintIErc20 = IERC20(_gego1.erc20);

        uint256 balanceBefore = mintIErc20.balanceOf(address(this));
        _factory.burn(costSet1.costErc721Id1);
        _factory.burn(costSet1.costErc721Id2);
        uint256 balanceEnd = mintIErc20.balanceOf(address(this));

        mintAmount = balanceEnd.sub(balanceBefore);
        mintErc20 = _gego1.erc20;

        super._airdrop(params.user);
    } 


    function generate( address user , uint256 ruleId) external view returns (  IGegoToken.Gego memory gego ){
        require( _factory == IGegoFactoryV2(msg.sender) ," invalid factory caller" );

        require(_gego1.grade == _gego2.grade, "invalid gego grade!");
        require(_gego1.tLevel == _gego2.tLevel, "invalid gego tLevel!");
        require(_gego1.erc20 == _gego2.erc20, "invalid gego erc20!");

        gego.tLevel = _gego1.tLevel.add(1);
        gego.grade = _gego1.grade;
        gego.amount = 0;
        gego.resBaseId = _gego1.resBaseId;

        require(gego.tLevel <= _maxTLevel, "invalid tLevel!");

        if( gego.tLevel == _maxTLevel ){
            require(_ruleData[ruleId].canMintMaxTLevel, "canMintMaxTLevel must be true");
        }

        gego.quality = getQuality(user,gego.grade);

    } 

    function getQuality(address user, uint256 grade) public view returns (uint256){
        uint256 seed = super.computerSeed(user);
        if(grade == 1 ){
            return seed%5000;
        }else if( grade == 2){
            return (seed%3000).add(5000);
        } else if( grade == 3){
            return (seed%1000).add(8000);
        } else if( grade == 4){
            return (seed%800).add(9000);
        } else if( grade == 5){
            return (seed%180).add(9800);
        } else {
            return (seed%20).add(9980);
        }
    }

}
