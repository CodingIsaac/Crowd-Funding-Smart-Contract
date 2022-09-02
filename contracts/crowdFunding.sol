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

    // For a request voting
    struct spendingRequest {
        string description;
        address payable fundingrecipient;
        uint value;
        bool completed;
        uint numberofVoters;
        mapping(address => bool) voters;
    }
    uint public fundingRaisedAmount;
    mapping (uint => spendingRequest) public requests;
    uint public numRequests;

    // Ease in interacting with the front end. 
    event CrowdFundingContribution (address _spender, uint _value);
    event CreatSpendingRequest(string _description, address _recipient, uint _value);
    event Transfer(address _recipient, uint _value);


    //  A modifier to determine the timestamp of the crowd funding

    modifier crowdFundingPeriod() {
        require(block.timestamp < deadline, "Deadline has Passed");
        _;
    }

    // A modifier to ensure that contibution is more than the minimum investment

    modifier minContributions() {
        require(msg.value >= minimumContribution, "The minimum Deposit is 0.2 Ether");
        _;
    }

    // A modifier which ensures that a function can only be called by the admin

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can start a Crowd Funding");
        _;
    }

    //  A modifier than ensures that once we exceed the funding cap, an error is thrown.
    modifier fundingcapExceeded() {
        require ( fundingRaisedAmount   >= fundingCap, "Amount for Crowd Funding Exceeded");
        _;
    }

    modifier refund() {
        require(block.timestamp > deadline && fundingRaisedAmount < fundingCap, "Funding Period and Funds Exceeded" );
        _;

    }

    modifier refundTwo() {
        require(fundingContributors[msg.sender] > 0, "Insufficient Funds");
        _;
    }

    modifier votingRight() {
        require(fundingContributors[msg.sender] > 0, "Sorry you are not a Contributor.");
        _;
    }
    
    //  Every function must be payable to receive ether.

    receive() external payable {
        fundingContribute();
    }
    fallback() external payable {}

    constructor(string memory _fundingGoal, uint _fundingCap,  uint _fundingdeadline) {
        goal = _fundingGoal;
        deadline = block.timestamp + _fundingdeadline;
        admin = msg.sender;
        minimumContribution = 0.2 ether;
        fundingCap = _fundingCap;
        
    }

    function fundingContribute() public payable crowdFundingPeriod  minContributions returns(uint) {
        if (fundingContributors[msg.sender] == 0) {
            noOfContributors++;
        }

        fundingContributors[msg.sender] += msg.value;
        return fundingRaisedAmount += msg.value;

        emit CrowdFundingContribution(msg.sender, msg.value);

    }

    function getBalance() public view onlyAdmin returns(uint) {
        return address(this).balance / 1 ether;
    }

    function getRefund() public refund refundTwo {
        address payable fundingRecipient;
        uint value = fundingContributors[msg.sender];
        fundingRecipient.transfer(value); 
        fundingContributors[msg.sender] = 0;
    }

    function createRequest(string calldata _description, address payable _recipient, uint _value) public onlyAdmin {
        spendingRequest storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.fundingrecipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numberofVoters = 0;

        emit CreatSpendingRequest(_description, _recipient, _value);

    }

    function voteRequest(uint _requestNumber) public votingRight {
        spendingRequest storage currentRequest = requests[_requestNumber];
        require(currentRequest.voters[msg.sender] == false, "You can only Vote Once");
        currentRequest.voters[msg.sender] = true;
        currentRequest.numberofVoters++;


    }

    function  makeFundingPayment(uint _paymentNo) public onlyAdmin fundingcapExceeded {
        spendingRequest storage thisRequest = requests[_paymentNo];
        require(thisRequest.completed == false, "This Request has been Completed!");
        require(thisRequest.numberofVoters > noOfContributors / 2, "Number of Contributors not Reached" );
        thisRequest.fundingrecipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit Transfer( thisRequest.fundingrecipient, thisRequest.value);


        
    }






}