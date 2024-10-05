// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/Business.sol";

contract BusinessTest is Test {
    Business business;
    address payable manager = payable(address(0x123));
    address user = address(0x456);

    function setUp() public {
        vm.prank(manager);
        business = new Business("John's Bakery", "JBK");
    }

    function testInitialValues() public view {
        assertEq(business.name(), "John's Bakery");
        assertEq(business.symbol(), "JBK");
        assertEq(business.manager(), manager);
        assertEq(business.decimals(), 18);
    }

    function testPurchase() public {
        // Simulate a purchase by sending ether
        uint256 purchaseAmount = 1 ether;
        vm.deal(user, purchaseAmount);
        vm.prank(user);
        business.purchase{value: purchaseAmount}("Item 1");

        // Check that the user received the loyal point (1 token)
        assertEq(business.balanceOf(user), 1);
    }

    function testWithdrawFunds() public {
        // Arrange
        uint256 initialBalance = address(manager).balance;
        uint256 withdrawAmount = 0.5 ether;

        // Deal some ether to the business contract
        vm.deal(address(business), 1 ether);

        // Act
        vm.prank(manager);
        business.withdrawFunds(withdrawAmount);

        // Assert
        assertEq(address(manager).balance, initialBalance + withdrawAmount);
        assertEq(address(business).balance, 0.5 ether); // Remaining balance in the contract
    }

    function testOnlyOwnerCanWithdraw() public {
        // Arrange
        uint256 withdrawAmount = 0.5 ether;
        vm.deal(address(business), 1 ether);

        // Act & Assert
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(user);
        business.withdrawFunds(withdrawAmount);
    }
}
