// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MonthlyReport {
    address public platform;

    constructor(address _platform) {
        platform = _platform;
    }

    modifier onlyPlatform() {
        require(msg.sender == platform, "Only platform can call");
        _;
    }

    struct CreatorData {
        uint256 totalNFTPublished;
        uint256 totalNFTShared;
        uint256 totalNFTValue;
        uint256 totalTransactions;
    }
    
    struct ReaderData {
        uint256 tokensChargedThisMonth;
        uint256 currentBalance;
    }
    
    struct InvestorData {
        uint256 tokensChargedThisMonth;
    }
    
    struct MonthlyData {
        CreatorData creator;
        ReaderData reader;
        InvestorData investor;
        bool exists;
    }
    
    mapping(uint256 => mapping(address => MonthlyData)) public monthlyReports;

    event CreatorDataUploaded(uint256 monthId, address indexed user, CreatorData data);
    event ReaderDataUploaded(uint256 monthId, address indexed user, ReaderData data);
    event BatchCreatorDataUploaded(uint256 monthId, uint256 count);
    event BatchReaderDataUploaded(uint256 monthId, uint256 count);

    function uploadCreatorData(
        uint256 monthId,
        address user,
        CreatorData calldata data
    ) external onlyPlatform {
        monthlyReports[monthId][user].creator = data;
        monthlyReports[monthId][user].exists = true;
        emit CreatorDataUploaded(monthId, user, data);
    }

    function uploadReaderData(
        uint256 monthId,
        address user,
        ReaderData calldata data
    ) external onlyPlatform {
        monthlyReports[monthId][user].reader = data;
        monthlyReports[monthId][user].exists = true;
        emit ReaderDataUploaded(monthId, user, data);
    }

    function batchUploadCreatorData(
        uint256 monthId,
        address[] calldata users,
        CreatorData[] calldata dataList
    ) external onlyPlatform {
        require(users.length == dataList.length, "Length mismatch");
        for (uint256 i = 0; i < users.length; i++) {
            monthlyReports[monthId][users[i]].creator = dataList[i];
            monthlyReports[monthId][users[i]].exists = true;
        }
        emit BatchCreatorDataUploaded(monthId, users.length);
    }

    function batchUploadReaderData(
        uint256 monthId,
        address[] calldata users,
        ReaderData[] calldata dataList
    ) external onlyPlatform {
        require(users.length == dataList.length, "Length mismatch");
        for (uint256 i = 0; i < users.length; i++) {
            monthlyReports[monthId][users[i]].reader = dataList[i];
            monthlyReports[monthId][users[i]].exists = true;
        }
        emit BatchReaderDataUploaded(monthId, users.length);
    }

    function getCreatorData(uint256 monthId, address user) external view returns (CreatorData memory) {
        return monthlyReports[monthId][user].creator;
    }

    function getReaderData(uint256 monthId, address user) external view returns (ReaderData memory) {
        return monthlyReports[monthId][user].reader;
    }

    function setPlatform(address newPlatform) external onlyPlatform {
        platform = newPlatform;
    }
}
