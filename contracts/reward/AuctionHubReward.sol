pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../interface/IERC20.sol";

import "../library/SafeERC20.sol";

contract AuctionHubReward is IERC721Receiver {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public _dandy = IERC20(0x0);
    uint256 public _rewardDandy = 1e16;
    uint256 _maxAddTime = 1 hours;
    bool private _initialized; // Flag of initialize data
    address public _governance;

    struct AuctioinObject {
        uint turn;

        address origin;
        IERC721 nft;
        address payable nftAuctionWallet;

        address payable curPlayer;

        uint256 baseRate;
        uint256 stepRate;
        uint256 rewardBackRate;

        uint256 startTime;
        uint256 durationTime;
        uint256 stepTime;

        uint256 curAuctionQuote;
        uint256 curTokenId;

        bool isTake;
        bool isStart;
    }

    uint256 public _auctionAmount = 0;

    AuctioinObject[] _auctioinObjects;
    uint8[] public _auctionStatus;

    mapping(address => bool) public _auctioneer;
    mapping(address => bool) public _verifyAuctioneer;
    bool public _isStartUserAuction;

    mapping (address => mapping (uint => uint256)) public _quoteHistory;
    mapping (address => mapping (uint => uint256)) public _earnHistory;

    event eveAuction(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveTurnEnd(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveNewTurn(uint256 curTurns,address curPlayer, uint256 curAuctionQuote,uint256 durationTime);
    event eveNewAuction(uint256 amount,address auctioneer, uint256 startQuote,uint256 startTime);

    event eveNFTReceived(address operator, address from, uint256 tokenId, bytes data);
    event eveNFTPassBy(uint256 tokenId, uint256 curAuctioinQuote);
    
    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    /**
     * check address
     */
    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        _;
    }

    modifier mustInAuctionTime(uint index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.startTime < now, "not start");
        require(obj.startTime.add(obj.durationTime) > now, "finish");
        _;
    }

    modifier checkTime(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        startCheck(obj);
        _;
    }

    modifier checkindex(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        _;
    }

    // modifier mustEndAuction(AuctioinObject obj) {
    //     require(obj.startTime.add(obj.durationTime) < now, "not finish");
    //     _;
    // }

    modifier mustEndAuction(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.startTime.add(obj.durationTime) < now, "not finish");
        _;
    }

    modifier onlyAuctionOwner(uint index) {
        require(index < _auctioinObjects.length, "overflow");
        AuctioinObject storage obj = _auctioinObjects[index];
        require(obj.origin == msg.sender || msg.sender == _governance, "author & governance");
        _;
    }


    // governance
    // --- Init ---
    function initialize() public {

        require(!_initialized, "initialize: Already initialized!");
        _governance = tx.origin;
        _rewardDandy = 1e16;
        _maxAddTime = 1 hours;
        _initialized = true;
    }


    function seize(IERC20 asset) external onlyGovernance returns (uint256 balance) {
        balance = asset.balanceOf(address(this));
        asset.safeTransfer(_governance, balance);
    }

    function() external payable {
        // auction();
        revert();
    }

    function setRewardDandy(uint256 rewardDandy) public onlyGovernance {
        _rewardDandy = rewardDandy;
    }

    function addAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _auctioneer[auctioneer] = true;
    }

    function removeAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _auctioneer[auctioneer] = false;
    }

    function addVerifyAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _verifyAuctioneer[auctioneer] = true;
    }

    function removeVerifyAuctioneer(address auctioneer) public onlyGovernance validAddress(auctioneer) {
        _verifyAuctioneer[auctioneer] = false;
    }

    function setIsStartUserAuction(bool isStartUserAuction) public onlyGovernance {
        _isStartUserAuction = isStartUserAuction;
    }

    function getAuctionEndTime(uint index) 
        external
        view
        checkindex(index)
        returns (uint256) 
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        return obj.startTime.add(obj.durationTime);
    }

    function getAuction(uint index) external view checkindex(index) returns(AuctioinObject memory) {
        return _auctioinObjects[index];
    }

    function getAucitonQuote(uint index)
        external
        view
        checkindex(index)
        returns (uint256)
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        if(obj.curPlayer != address(0x0)) {
            return obj.curAuctionQuote.add(obj.curAuctionQuote.mul(obj.stepRate).div(obj.baseRate));
        } else {
            return obj.curAuctionQuote;
        }
        
    }

    function setDandyAddress(address addr) external onlyGovernance validAddress(addr) {
        _dandy = IERC20(addr);
    }

    function setMaxAddTime(uint256 maxAddTime) external onlyGovernance {
        _maxAddTime = maxAddTime;
    }

    function setBaseRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(rate >= obj.rewardBackRate, "invalid base rate");
        obj.baseRate = rate;
    }

    function setRewardBackRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(rate <= obj.baseRate, "invalid reward return back rate");
        obj.rewardBackRate = rate;
    }

    function setStepRate(uint index, uint256 rate) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.stepRate = rate;
    }

    function setDurationTime(uint index, uint256 duration) external onlyAuctionOwner(index) {
        uint status = _auctionStatus[index];
        require(status == 0 || status == 1, "has over");
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.durationTime = duration;
    }

    function setStepTime(uint index, uint256 stepTime) external onlyAuctionOwner(index) {
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.stepTime = stepTime;
    }

    function setStartTime(uint index, uint256 startTime) external onlyAuctionOwner(index) {
        uint status = _auctionStatus[index];
        require(status == 0, "has start");
        AuctioinObject storage obj = _auctioinObjects[index];
        obj.startTime = startTime;
    }


    function setGovernance(address governance) external  onlyGovernance{
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


    function getHistory(uint index) public view checkindex(index) returns(uint256 quote, uint256 earn) {
        quote = _quoteHistory[msg.sender][index];
        earn = _earnHistory[msg.sender][index];
    }

    function isVerifyAuction(uint index) public view checkindex(index) returns(bool) {
        AuctioinObject storage obj = _auctioinObjects[index];
        return _verifyAuctioneer[obj.origin];
    }

    function startAuction(uint256 tokenId,
                        uint256 startQuote, 
                        uint256 startTime, 
                        uint256 durationTime,
                        uint256 stepTime,
                        address nft,
                        address payable nftAuctionWallet)
        external 
        validAddress(nft)
        validAddress(nftAuctionWallet)
    {
        require(tokenId != 0, "invalid token");
        require(startTime.add(durationTime) > now, "invalid time");
        require(durationTime != 0, "invalid duration");
        require(_isStartUserAuction || _auctioneer[msg.sender] == true, "cannot auction");

        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        AuctioinObject memory obj;

        obj.nft = IERC721(nft);
        obj.nftAuctionWallet = nftAuctionWallet;
        obj.baseRate = 1000;
        obj.stepRate = 100;
        obj.rewardBackRate = 800;
        obj.curTokenId = tokenId;
        obj.curAuctionQuote = startQuote;
        obj.startTime = startTime;
        obj.durationTime = durationTime;
        obj.stepTime = stepTime;
        obj.curPlayer = address(0x0);
        obj.origin = msg.sender;
        obj.isTake = false;

        _auctionAmount++;
        obj.turn = _auctionAmount;
        obj.isStart = false;

        _auctioinObjects.push(obj);
        _auctionStatus.push(0);

        emit eveNewAuction(_auctionAmount, msg.sender, startQuote, startTime);
    }

    function getReward(uint index) external checkTime(index) mustEndAuction(index) returns(bool) {
        AuctioinObject storage obj = _auctioinObjects[index];
        require(!obj.isTake, "nft has been taken");

        if(obj.curPlayer == address(0x0)) {
            obj.nft.safeTransferFrom(address(this), obj.origin, obj.curTokenId);
        } else {
            obj.nft.safeTransferFrom(address(this), obj.curPlayer, obj.curTokenId);
        }
        obj.isTake = true;
        return true;
    }

    function endCheck(AuctioinObject storage obj) internal {
        if( !obj.isStart ){
            return;
        }
        if(obj.startTime.add(obj.durationTime) > now){
            return;
        }

        obj.isTake = false;
        obj.isStart = false;
        _auctionStatus[obj.turn - 1] = 2;

        emit eveTurnEnd( obj.turn, obj.curPlayer, obj.curAuctionQuote, obj.durationTime);
    }

    function startCheck(AuctioinObject storage obj) internal {
        if (obj.isStart) {
            endCheck(obj);
            return;
        }

        if(obj.startTime < now && obj.startTime.add(obj.durationTime) > now) {
            obj.isStart = true;
            _auctionStatus[obj.turn - 1] = 1;
            // _curAuctionQuote = 0;
            obj.curPlayer = address(0x0);
            emit eveNewTurn( obj.turn, obj.curPlayer, obj.curAuctionQuote, obj.durationTime);
        }
    }

    function auction(uint index)
        public
        mustInAuctionTime(index)
        checkTime(index)
        payable 
    {
        AuctioinObject storage obj = _auctioinObjects[index];
        require( obj.isStart, "auction do not open yet!");
        require (msg.value >= this.getAucitonQuote(index), "umm.....  your quote is too low");
        uint256 back = msg.value.sub(this.getAucitonQuote(index));
        if(back > 0) {
            msg.sender.transfer(back);
        }
        uint256 realAuction = msg.value.sub(back);
        if(obj.curPlayer != address(0x0)) {
            uint256 spread = realAuction.sub(obj.curAuctionQuote);
            uint256 returnRewardAmount = spread.mul(obj.rewardBackRate).div(obj.baseRate);
            uint256 returnBackAmount = obj.curAuctionQuote.add(returnRewardAmount);

            obj.curPlayer.transfer(returnBackAmount);

            _earnHistory[obj.curPlayer][index] = _earnHistory[obj.curPlayer][index].add(returnRewardAmount);

            uint256 rewardAmount = spread.sub(returnRewardAmount);
            if(rewardAmount > 0) {
                obj.nftAuctionWallet.transfer(rewardAmount);
            }
        } else {
            obj.nftAuctionWallet.transfer(realAuction);
        }

        if(this.isVerifyAuction(index)) {
            _dandy.mint(msg.sender, _rewardDandy);
        }

        obj.curAuctionQuote = realAuction;
        obj.curPlayer = msg.sender;
        _quoteHistory[msg.sender][index] = realAuction;

        uint256 endTime = this.getAuctionEndTime(index);
        uint256 offset = endTime.sub(now);
        if(offset <= _maxAddTime) {
            uint256 slot = _maxAddTime.sub(offset);
            if(slot <= obj.stepTime) {
                obj.durationTime = obj.durationTime.add(slot);
            } else {
                obj.durationTime = obj.durationTime.add(obj.stepTime);
            }
        }
        
        // fire event
        emit eveAuction(index, msg.sender, realAuction, obj.durationTime);
    }

    function getAuctionsStatus() public view returns(uint8[] memory) {
        return _auctionStatus;
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
