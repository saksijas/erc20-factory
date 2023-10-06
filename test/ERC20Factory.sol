// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;


import "forge-std/Test.sol";
import "../src/ERC20Factory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MockCurrency is ERC20, Test {
    address addressA = vm.addr(1);

    constructor() ERC20("Mock Currency", "MC") {
        _mint(address(addressA), 100_000 * 10 ** 18);
    }
}


contract ERC20FactoryTest is Test {
    MockCurrency mockCurrency;
    ERC20FactoryTest erc20Factory;
    ERC20 erc20Test;
    address gnosis = vm.addr(1);
    address firstUser = vm.addr(2);
    address secondUser = vm.addr(3);
    
    event ERC20Created(address indexed token, address indexed owner);
    event FeePaid(address indexed payer, int256 fee);

    function setUp() public {
        erc20Factory = new ERC20Factory(gnosis, 1);
    }

    function testCreateERC20TokenTest() public {
        vm.startPrank(firstUser);

        // emit the ERC20Created event correctly
        vm.expectEmit(true, true, true, true);
        emit ERC20Created(1, address(erc20Test), 0);

        erc20Factory.createERC20("Test Token", "TTKN",1);
        vm.stopPrank();
        assertEq(erc20Test.balanceOf(firstUser), 1);
        assertEq(erc20Test.totalSupply(), 1);
        assertEq(erc20Test.name(), "Test Token");
        assertEq(erc20Test.symbol(), "TTKN");
        assertEq(erc20Test.owner(), firstUser);
    }

}