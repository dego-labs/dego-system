pragma solidity ^0.5.5;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../library/Governance.sol";

/// @title DandyToken Contract

contract DandyToken is Governance, ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    // for minters
    mapping(address => bool) public _minters;

    //token base data
    uint256 internal _totalSupply;
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

    /**
     * CONSTRUCTOR
     *
     * @dev Initialize the Token
     */

    constructor() public ERC20Detailed("dandy.dego", "DANDY", 18) {}

    function mint(address account, uint256 amount) public {
        require(_minters[msg.sender], "!minter");
        _mint(account, amount);
    }


    function addMinter(address minter) public onlyGovernance{
        _minters[minter] = true;
    }

    function removeMinter(address minter) public onlyGovernance {
        _minters[minter] = false;
    }
}
