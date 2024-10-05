// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract Community is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    // GovernorVotesQuorumFraction(90) Percentage of total supply of tokens needed to aprove proposals (89%)

    /*
    2 days = 13,292 blocks
    1 week = 46,523 blocks
    GovernorSettings(7200, 46_523, 0) Parameters display the number of blocks 
    Voting Delay - The delay from when a proposal is created until voting begins.
    Voting Period - The length of time people can vote.
    Proposal Threshold - The minimum number of votes an account must have to create a proposal
    */

    constructor(IVotes _token, TimelockController _timelock)
        Governor("Community Governor")
        GovernorSettings(13_292, 46_523, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(90)
        GovernorTimelockControl(_timelock)
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    // function proposalNeedsQueuing(uint256 proposalId)
    //     public
    //     view
    //     override(Governor, GovernorTimelockControl)
    //     returns (bool)
    // {
    //     return super.proposalNeedsQueuing(proposalId);
    // }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    // function _queueOperations(
    //     uint256 proposalId,
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     bytes32 descriptionHash
    // ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
    //     return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    // }

    // function _executeOperations(
    //     uint256 proposalId,
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     bytes32 descriptionHash
    // ) internal override(Governor, GovernorTimelockControl) {
    //     super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    // }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        super.supportsInterface(interfaceId);
    }
}
