// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract crowdFunding {
    mapping (address => uint) public fundingContributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline;
    uint public fundingCap;
    string public goal;
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
    modifier fundingcapExceeded() {
        require ( fundingCap >= fundingRaisedAmount , "Amount for Crowd Funding Exceeded");
        _;
    }

    receive() external payable {
        fundingContribute();
    }
    fallback() external payable {}

    constructor(string memory _fundingGoal, uint _fundingdeadline) {
        goal = _fundingGoal;
        deadline = block.timestamp + _fundingdeadline;
        admin = msg.sender;
        minimumContribution = 0.2 ether;
        fundingCap = 4 ether;
        
    }

    function fundingContribute() public payable crowdFundingPeriod fundingcapExceeded  minContributions returns(uint) {
        if (fundingContributors[msg.sender] == 0) {
            noOfContributors++;
        }

        fundingContributors[msg.sender] += msg.value;
        return fundingRaisedAmount += msg.value;

    }

    function getBalance() public view onlyAdmin returns(uint) {
        return address(this).balance;
    }






}