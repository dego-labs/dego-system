pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../interface/IERC20.sol";

import "../library/SafeERC20.sol";
import "../library/Governance.sol";

contract NFTPlayerOpenSales is IERC721Receiver, Governance {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _dandy = IERC20(0x0);

    struct SalesObject {
        uint id;

        address payable origin;
        IERC721 nft;

        address payable curBuyer;

        uint256 startTime;
        uint256 durationTime;

        uint256 maxPrice;
        uint256 minPrice;

        uint256 curTokenId;

        uint256 finalPrice;

        uint8 status;
    }

    uint256 public _salesAmount = 0;

    SalesObject[] _salesObjects;
    uint8[] public _salesStatus;

    mapping(address => bool) public _seller;
    mapping(address => bool) public _verifySeller;
    mapping(address => bool) public _supportNft;
    bool public _isStartUserSales;

    bool public _isRewardSellerDandy = false;
    bool public _isRewardBuyerDandy = false;


    uint256 public _sellerRewardDandy = 1e15;
    uint256 public _buyerRewardDandy = 1e15;

    uint256 public _tipsFeeRate = 20;
    uint256 public _baseRate = 1000;

    uint256 public _minDurationTime = 5 minutes;

    address payable _tipsFeeWallet;

    event eveSales(uint256 id,address curBuyer, uint256 price, uint256 tipsFee);
    event eveNewSales(uint256 id, address seller, uint256 maxPrice, uint256 minPrice, uint256 startTime);
    event eveCancelSales(uint256 id);
    event eveNFTReceived(address operator, address from, uint256 tokenId, bytes data);

    /**
     * check address
     */
    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        _;
    }

    modifier checkindex(uint index) {
        require(index < _salesObjects.length, "overflow");
        _;
    }

    modifier checkTime(uint index) {
        require(index < _salesObjects.length, "overflow");
        SalesObject storage obj = _salesObjects[index];
        require(obj.startTime <= now, "!open");
        _;
    }


    modifier mustNotSellingOut(uint index) {
        require(index < _salesObjects.length, "overflow");
        SalesObject storage obj = _salesObjects[index];
        require(obj.curBuyer == address(0x0) && obj.status == 0, "sry, selling out");
        _;
    }

    modifier onlySalesOwner(uint index) {
        require(index < _salesObjects.length, "overflow");
        SalesObject storage obj = _salesObjects[index];
        require(obj.origin == msg.sender || msg.sender == _governance, "author & governance");
        _;
    }

    function seize(IERC20 asset) external onlyGovernance returns (uint256 balance) {
        balance = asset.balanceOf(address(this));
        asset.safeTransfer(_governance, balance);
    }

    function() external payable {
        revert();
    }

    function setSellerRewardDandy(uint256 rewardDandy) public onlyGovernance {
        _sellerRewardDandy = rewardDandy;
    }

    function setBuyerRewardDandy(uint256 rewardDandy) public onlyGovernance {
        _buyerRewardDandy = rewardDandy;
    }

    function addSupportNft(address nft) public onlyGovernance validAddress(nft) {
        _supportNft[nft] = true;
    }

    function removeSupportNft(address nft) public onlyGovernance validAddress(nft) {
        _supportNft[nft] = false;
    }

    function addSeller(address seller) public onlyGovernance validAddress(seller) {
        _seller[seller] = true;
    }

    function removeSeller(address seller) public onlyGovernance validAddress(seller) {
        _seller[seller] = false;
    }

    function addVerifySeller(address seller) public onlyGovernance validAddress(seller) {
        _verifySeller[seller] = true;
    }

    function removeVerifySeller(address seller) public onlyGovernance validAddress(seller) {
        _verifySeller[seller] = false;
    }

    function setIsStartUserSales(bool isStartUserSales) public onlyGovernance {
        _isStartUserSales = isStartUserSales;
    }

    function setIsRewardSellerDandy(bool isRewardSellerDandy) public onlyGovernance {
        _isRewardSellerDandy = isRewardSellerDandy;
    }

    function setIsRewardBuyerDandy(bool isRewardBuyerDandy) public onlyGovernance {
        _isRewardBuyerDandy = isRewardBuyerDandy;
    }

    function setMinDurationTime(uint256 durationTime) public onlyGovernance {
        _minDurationTime = durationTime;
    }

    function setTipsFeeWallet(address payable wallet) public onlyGovernance {
        _tipsFeeWallet = wallet;
    }

    function getSalesEndTime(uint index) 
        external
        view
        checkindex(index)
        returns (uint256) 
    {
        SalesObject storage obj = _salesObjects[index];
        return obj.startTime.add(obj.durationTime);
    }

    function getSales(uint index) external view checkindex(index) returns(SalesObject memory) {
        return _salesObjects[index];
    }

    function getSalesPrice(uint index)
        external
        view
        checkindex(index)
        returns (uint256)
    {
        SalesObject storage obj = _salesObjects[index];
        if(obj.curBuyer != address(0x0) || obj.status == 1) {
            return obj.finalPrice;
        } else {
            if(obj.startTime.add(obj.durationTime) < now) {
                return obj.minPrice;
            } else if (obj.startTime >= now) {
                return obj.maxPrice;
            } else {
                uint256 per = obj.maxPrice.sub(obj.minPrice).div(obj.durationTime);
                return obj.maxPrice.sub(now.sub(obj.startTime).mul(per));
            }
        }
    }

    function setDandyAddress(address addr) external onlyGovernance validAddress(addr) {
        _dandy = IERC20(addr);
    }

    function setBaseRate(uint256 rate) external onlyGovernance {
        _baseRate = rate;
    }

    function setTipsFeeRate(uint256 rate) external onlyGovernance {
        _tipsFeeRate = rate;
    }

    function isVerifySeller(uint index) public view checkindex(index) returns(bool) {
        SalesObject storage obj = _salesObjects[index];
        return _verifySeller[obj.origin];
    }

    function cancelSales(uint index) external checkindex(index) onlySalesOwner(index) mustNotSellingOut(index)  {
        SalesObject storage obj = _salesObjects[index];
        obj.status = 2;
        _salesStatus[index] = 2;
        obj.nft.safeTransferFrom(address(this), obj.origin, obj.curTokenId);

        emit eveCancelSales(index);
    }

    function startSales(uint256 tokenId,
                        uint256 maxPrice, 
                        uint256 minPrice,
                        uint256 startTime, 
                        uint256 durationTime,
                        address nft)
        external 
        validAddress(nft)
        returns(uint)
    {
        require(tokenId != 0, "invalid token");
        require(startTime.add(durationTime) > now, "invalid start time");
        require(durationTime >= _minDurationTime, "invalid duration");
        require(maxPrice >= minPrice, "invalid price");
        require(_isStartUserSales || _seller[msg.sender] == true || _supportNft[nft] == true, "cannot sales");

        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        SalesObject memory obj;

        obj.nft = IERC721(nft);
        obj.curTokenId = tokenId;
        obj.startTime = startTime;
        obj.durationTime = durationTime;
        obj.curBuyer = address(0x0);
        obj.origin = msg.sender;
        obj.finalPrice = 0;
        obj.maxPrice = maxPrice;
        obj.minPrice = minPrice;
        obj.status = 0;

        _salesAmount++;
        obj.id = _salesAmount;

        _salesObjects.push(obj);
        _salesStatus.push(0);

        if(_isRewardSellerDandy || _verifySeller[msg.sender]) {
            _dandy.mint(msg.sender, _sellerRewardDandy);
        }

        emit eveNewSales(_salesAmount, msg.sender, maxPrice, minPrice, startTime);
        return _salesAmount;
    }

    function buy(uint index)
        public
        mustNotSellingOut(index)
        checkTime(index)
        payable 
    {
        SalesObject storage obj = _salesObjects[index];
        require (msg.value >= this.getSalesPrice(index), "umm.....  your price is too low");
        uint256 price = this.getSalesPrice(index);
        uint256 returnBack = msg.value.sub(price);
        if(returnBack > 0) {
            msg.sender.transfer(returnBack);
        }

        uint256 tipsFee = price.mul(_tipsFeeRate).div(_baseRate);
        uint256 purchase = price.sub(tipsFee);

        if(_isRewardBuyerDandy || _verifySeller[obj.origin]) {
            _dandy.mint(msg.sender, _buyerRewardDandy);
        }

        if(tipsFee > 0) {
            _tipsFeeWallet.transfer(tipsFee);
        }

        obj.origin.transfer(purchase);
        obj.nft.safeTransferFrom(address(this), msg.sender, obj.curTokenId);
        
        obj.curBuyer = msg.sender;
        obj.finalPrice = price;

        obj.status = 1;
        _salesStatus[index] = 1;

        // fire event
        emit eveSales(index, msg.sender, price, tipsFee);
    }

    function getSalesStatus(uint index, uint step) public view returns(uint8[] memory) {
        uint8[] memory result;
        for(uint i = index; i < step; i++) {
            result[i - index] = _salesStatus[i];
        }
        return result;
    }
    

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        //only receive the _nft staff
        if(address(this) != operator) {
            //invalid from nft
            return 0;
        }

        //success
        emit eveNFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
