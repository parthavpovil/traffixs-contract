// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReportAndReward {
    struct ReportData {
        uint256 id;
        address reporter;
        string description;
        string location;
        string evidenceLink; // IPFS hash of the evidence
        bool verified;
        uint256 reward;
        uint256 timestamp;
    }

    ReportData[] public reports;

    // New public variable to count the number of reports submitted
    uint256 public reportCount;

    address public owner;

    event ReportSubmitted(uint256 indexed id, address indexed reporter);
    event ReportVerified(uint256 indexed id, address indexed reporter, uint256 reward);

    constructor() payable {
        owner = msg.sender;
        reportCount = 0; // Initialize report count
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function submitReport(string memory _description, string memory _location, string memory _evidenceLink) public {
        uint256 id = reports.length;
        reports.push(ReportData({
            id: id,
            reporter: msg.sender,
            description: _description,
            location: _location,
            evidenceLink: _evidenceLink,
            verified: false,
            reward: 0, // Default reward, to be set during verification
            timestamp: block.timestamp
        }));

        reportCount++; // Increment the report count

        emit ReportSubmitted(id, msg.sender);
    }

    function verifyReport(uint256 _id, uint256 _newReward) public payable onlyOwner {
        ReportData storage report = reports[_id];
        require(report.verified == false, "Report already verified");

        // Set or update the reward amount
        report.reward = _newReward;

        // Mark the report as verified
        report.verified = true;

        // Transfer the reward to the reporter
        payable(report.reporter).transfer(report.reward);

        // Emit an event to log the verification and reward transfer
        emit ReportVerified(_id, report.reporter, report.reward);
    }

    // New function to get reports by reporter address
    function getReportsByAddress(address _reporter) public view returns (ReportData[] memory) {
        uint256 reportCountByUser = 0;
        
        // Count how many reports belong to the given reporter
        for (uint256 i = 0; i < reports.length; i++) {
            if (reports[i].reporter == _reporter) {
                reportCountByUser++;
            }
        }

        // Create an array to hold the reports for the given address
        ReportData[] memory userReports = new ReportData[](reportCountByUser);
        uint256 index = 0;

        // Populate the array with the user's reports
        for (uint256 i = 0; i < reports.length; i++) {
            if (reports[i].reporter == _reporter) {
                userReports[index] = reports[i];
                index++;
            }
        }

        return userReports;
    }

    // Fallback function to receive Ether into the contract
    receive() external payable {}
}
