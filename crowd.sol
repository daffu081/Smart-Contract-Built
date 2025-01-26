// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner; // Address of the project owner
    uint public targetAmount; // Goal amount for the project
    uint public deadline; // Deadline for the crowdfunding
    uint public totalFunds; // Total funds raised
    mapping(address => uint) public contributions; // Track contributions by each address
    bool public targetReached;

    // Events for logging
    event ContributionReceived(address contributor, uint amount);
    event FundsWithdrawn(address owner, uint amount);
    event RefundIssued(address contributor, uint amount);

    constructor(uint _targetAmount, uint _durationInDays) {
        owner = msg.sender;
        targetAmount = _targetAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
        targetReached = false;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // Function to contribute to the crowdfunding
    function contribute() public payable {
        require(block.timestamp < deadline, "Crowdfunding has ended");
        require(msg.value > 0, "Contribution must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        emit ContributionReceived(msg.sender, msg.value);

        // Check if the target has been reached
        if (totalFunds >= targetAmount) {
            targetReached = true;
        }
    }

    // Function to withdraw funds by the owner if the target is met
    function withdrawFunds() public onlyOwner {
        require(block.timestamp > deadline, "Crowdfunding is still ongoing");
        require(targetReached, "Target not reached");

        uint amount = address(this).balance;
        totalFunds = 0; // Reset funds after withdrawal

        payable(owner).transfer(amount);
        emit FundsWithdrawn(owner, amount);
    }

    // Function to issue refunds if the target was not met
    function issueRefund() public {
        require(block.timestamp > deadline, "Crowdfunding is still ongoing");
        require(!targetReached, "Target was reached; no refunds");

        uint contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);

        emit RefundIssued(msg.sender, contributedAmount);
    }

    // Check contract balance (helpful for debugging/testing)
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
