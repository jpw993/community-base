// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../src/Community.sol";
import "../src/CommunityToken.sol";

contract CommunityDAOTest is Test {
    Community public communityDao;
    CommunityToken public token;
    TimelockController public timelock;
    address public owner;
    address public addr1;
    address public addr2;

    function setUp() public {
        // Deploy a simple ERC20Votes token for voting
        token = new CommunityToken();

        // Transfer tokens to voters
        token.transfer(address(this), 100 ether);
        token.transfer(address(1), 100 ether);
        token.transfer(address(2), 100 ether);

        address[] memory proposers = new address[](1);
        proposers[0] = address(this);

        address[] memory executors = new address[](1);
        executors[0] = address(0); // Allow anyone to execute

        // Deploy TimelockController (delay of 2 days)
        timelock = new TimelockController(2 days, proposers, executors, address(this));

        // Deploy the DAO contract
        communityDao = new Community(token, timelock);

        // Grant the DAO contract the proposer role
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(communityDao));

        // Delegate voting power
        token.delegate(address(this));
        vm.prank(address(1));
        token.delegate(address(1));
        vm.prank(address(2));
        token.delegate(address(2));
    }

    function testCreateAndVoteOnProposal() public {
        // Create a proposal

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(this);

        values[0] = 0;

        calldatas[0] = abi.encodeWithSignature("votingPeriod()");

        string memory description = "Proposal #1: Change voting period";

        uint256 proposalId = communityDao.propose(targets, values, calldatas, description);

        // Assert proposal state is Created (0)
        assertEq(uint256(communityDao.state(proposalId)), 0);

        // Simulate block mining to enter the voting period
        vm.roll(block.number + communityDao.votingDelay() + 1);

        // Cast votes
        communityDao.castVote(proposalId, 1); // Vote For
        vm.prank(address(1));
        communityDao.castVote(proposalId, 0); // Vote Against
        vm.prank(address(2));
        communityDao.castVote(proposalId, 1); // Vote For

        // Fast forward to after the voting period ends
        vm.roll(block.number + communityDao.votingPeriod() + 1);

        // Assert proposal is successful (Succeeded state)
        assertEq(uint256(communityDao.state(proposalId)), 4);

        // Queue the proposal for execution
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        communityDao.queue(targets, values, calldatas, descriptionHash);

        // Execute the proposal
        // communityDao.execute(targets, values, calldatas, descriptionHash);

        // // Assert the proposal is executed (Executed state)
        // assertEq(uint256(communityDao.state(proposalId)), 7);
    }
}
