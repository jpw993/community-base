// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Business is Ownable, ERC20 {
    address payable public immutable manager;

    constructor(address _manager, string memory _businessName, string memory _tokenCode)
        Ownable()
        ERC20(_businessName, _tokenCode)
    {
        manager = payable(_manager);
    }

    function decimals() public pure override(ERC20) returns (uint8) {
        return 18;
    }

    function withdrawFunds(uint256 amt) external onlyOwner {
        return manager.transfer(amt);
    }

    function purchase() external payable {
        // give the customer one loyal point for this purchase
        super._mint(msg.sender, 1);
    }
}
