// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract crowdFunding {
    mapping (address => uint) public fundingContributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public goal;
    uint public fundingRaisedAmount;

    modifier crowdFundingPeriod() {
        require(block.timestamp < deadline, "Deadline has Passed");
        _;
    }

    modifier minContributions() {
        require(msg.value >= minimumContribution, "The minimum Deposit is 0.2 Ether");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can start a Crowd Funding");
        _;
    }

    constructor(uint _fundingGoal, uint _fundingdeadline) {
        goal = _fundingGoal;
        deadline = block.timestamp + _fundingdeadline;
        admin = msg.sender;
        minimumContribution = 0.2 ether;
    }

    




}