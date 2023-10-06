// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

enum TokenType {
    Basic,
    Capped,
    Burnable,
    Pausable,
    CappedBurnable,
    CappedPausable,
    BurnablePausable,
    CappedBurnablePausable
}

contract ERC20Factory is Ownable {
    using SafeERC20 for IERC20;
    address private gnosis; 
    int256 private mintFee;
    address private constant ETH =
        address(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa);

    event ERC20Created(address indexed token, address indexed owner, TokenType tokenType);
    event FeePaid(address indexed payer, int256 fee);
    
    constructor(address _gnosis, int256 _fee){
        gnosis = _gnosis;
        mintFee = _fee;
    }
    struct Flags{
        bool isCapped;
        bool isBurnable;
        bool isPausable;
    }

    function CreateToken(Flags memory flags,string memory name, string memory symbol, uint256 initialSupply, uint256 cap) external returns (address) {
        require(msg.value == mintFee, "ERC20Factory: mint fee not met");

        if(flags.isCapped && flags.isBurnable && flags.isPausable){
            return createERC20CappedBurnablePausable(name, symbol, initialSupply, cap);
        } if(flags.isCapped && flags.isBurnable){
            return createERC20CappedBurnable(name, symbol, initialSupply, cap);
        } if(flags.isCapped && flags.isPausable){
            return createERC20CappedPausable(name, symbol, initialSupply, cap);
        } if(flags.isBurnable && flags.isPausable){
            return createERC20BurnablePausable(name, symbol, initialSupply);
        } if(flags.isCapped){
            return createERC20Capped(name, symbol, initialSupply, cap);
        } if (flags.isBurnable){
            return createERC20Burnable(name, symbol, initialSupply);
        } if (flags.isPausable){
            return createERC20Pausable(name, symbol, initialSupply);
        } else {
            return createERC20(name, symbol, initialSupply);
        }

        (bool sent, bytes memory data) = gnosis.call{value: mintFee}("");
        require(sent, "Failed to send Ether");
        emit FeePaid(msg.sender, mintFee);
    }

    function createERC20(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) private returns (address) {

        ERC20 erc20 = new ERC20(name, symbol, initialSupply);
        erc20.transfer(msg.sender, initialSupply);

        return address(erc20);
    }

    function createERC20Capped(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 cap
    ) private returns (address) {

        ERC20 erc20 = new ERC20Capped(name, symbol, initialSupply, cap);
        erc20.transfer(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.Capped);
        
        return address(erc20);
    }

    function createERC20Burnable(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) private returns (address) {

        ERC20Burnable erc20 = new ERC20Burnable(name, symbol, initialSupply);
        erc20.transfer(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.Burnable);

        return address(erc20);
    }

    function createERC20Pausable(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) private returns (address) {

        ERC20Pausable erc20 = new ERC20Pausable(name, symbol);
        erc20.mint(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.Pausable);

        return address(erc20);
    }

    function reateERC20CappedBurnablePausable(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 cap
    ) private returns (address) {

        ERC20CappedBurnablePausable erc20 = new ERC20CappedBurnablePausable(name, symbol, initialSupply, cap);
        erc20.mint(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.CappedBurnablePausable);

        return address(erc20);
    }

    function createERC20CappedBurnable(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 cap
    ) private returns (address) {

        ERC20CappedBurnable erc20 = new ERC20CappedBurnable(name, symbol, initialSupply, cap);
        erc20.mint(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.CappedBurnable);

        return address(erc20);
    }

    function createERC20CappedPausable(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 cap
    ) private returns (address) {

        ERC20CappedPausable erc20 = new ERC20CappedPausable(name, symbol, initialSupply, cap);
        erc20.mint(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.CappedPausable);

        return address(erc20);
    }

    function createERC20BurnablePausable(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) private returns (address) {

        ERC20BurnablePausable erc20 = new ERC20BurnablePausable(name, symbol, initialSupply);
        erc20.mint(msg.sender, initialSupply);
        emit ERC20Created(address(erc20), msg.sender, TokenType.BurnablePausable);

        return address(erc20);
    }

    function updateFee (int256 newFee) onlyOwner {
        mintFee = newFee;
    }
}