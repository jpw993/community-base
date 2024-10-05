// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CommunityToken is ERC20Votes {
    // Define the total supply
    uint256 public constant INITIAL_SUPPLY = 1000000 * (10 ** 18); // 1 million tokens with 18 decimals

    constructor()
        ERC20("Community Token", "CTK")
        ERC20Permit("Community Token") // Required for ERC20Votes
    {
        // Mint the initial supply to the deployer of the contract
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
