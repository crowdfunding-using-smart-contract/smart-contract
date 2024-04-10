// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Escrow.sol";

contract MockCrowdfunding is Ownable {
    IERC20 private _token;

    constructor(IERC20 tokenAddress) Ownable(msg.sender) {
        _token = tokenAddress;
    }

    struct Project {
        uint256 id;
        string title;
        uint256 targetFunding;
        uint256 currentFunding;
        uint256 startDate;
        uint256 endDate;
        address owner;
        STATUS status;
        uint256 count_contributors;
    }

    enum STATUS {
        ACTIVE,
        DELETED,
        SUCCESSFUL,
        UNSUCCESSFUL
    }

    uint256 private _projectIds;
    mapping(uint256 => Project) public projects;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event ProjectCreated(uint256 indexed projectId, string title, address owner);
    event ContributionMade(uint256 indexed projectId, uint256 amount, address contributor);
    event ContributionRefunded(uint256 indexed projectId, address contributor);

    function createProject(
        string memory title,
        uint256 targetFunding,
        uint256 startDate,
        uint256 endDate
    ) public returns (Project memory) {
        _projectIds++;
        uint256 newProjectId = _projectIds;

        projects[newProjectId] = Project({
            id: newProjectId,
            title: title,
            targetFunding: targetFunding,
            currentFunding: 0,
            startDate: startDate,
            endDate: endDate,
            owner: payable(msg.sender),
            status: STATUS.ACTIVE,
            count_contributors: 0
        });

        emit ProjectCreated(newProjectId, title, msg.sender);

        return Project({
            id: newProjectId,
            title: title,
            targetFunding: targetFunding,
            currentFunding: 0,
            startDate: startDate,
            endDate: endDate,
            owner: msg.sender,
            status: STATUS.ACTIVE,
            count_contributors: 0
        });
    }

    function contribute(uint256 projectId, uint256 amount) public {
        Project storage project = projects[projectId];
        require(project.status == STATUS.ACTIVE, "Project must be active");
        require(block.timestamp >= project.startDate && block.timestamp <= project.endDate, "Not in funding period");
        require(amount > 0, "Contribution must be greater than 0");

        require(_token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        project.currentFunding += amount;
        contributions[projectId][msg.sender] += amount;
        project.count_contributors += 1;

        emit ContributionMade(projectId, amount, msg.sender);

        if (project.currentFunding >= project.targetFunding) {
            project.status = STATUS.SUCCESSFUL;
        }
    }

    function refund(uint256 projectId) public {
        Project storage project = projects[projectId];
        uint256 contributedAmount = contributions[projectId][msg.sender];
        
        require(contributedAmount > 0, "No contributions to refund");
        require(project.status == STATUS.UNSUCCESSFUL || (project.status == STATUS.ACTIVE && block.timestamp > project.endDate), "Refunds not allowed");
        
        contributions[projectId][msg.sender] = 0;
        project.currentFunding -= contributedAmount;

        require(_token.transfer(msg.sender, contributedAmount), "Refund failed");

        emit ContributionRefunded(projectId, msg.sender);
    }

    function deleteProject(uint256 projectId) public {
        require(msg.sender == projects[projectId].owner, "Only the owner can delete the project.");
        projects[projectId].status = STATUS.DELETED;
    }

    function getAllProjects() public view returns (Project[] memory) {
        uint256 projectCount = _projectIds;

        Project[] memory filteredProjects = new Project[](projectCount);
        uint256 filteredIndex = 0;
        for (uint256 i = 1; i <= projectCount; i++) {
            filteredProjects[filteredIndex] = projects[i];
            filteredIndex++;
        }

        return filteredProjects;
    }

    function getProject(uint256 projectId) public view returns (Project memory) {
        return projects[projectId];
    }

    function editProject(
        uint256 projectId,
        string memory title,
        uint256 targetFunding,
        uint256 startDate,
        uint256 endDate
    ) public {
        require(msg.sender == projects[projectId].owner, "Only the owner can edit the project.");
        Project storage project = projects[projectId];

        if (bytes(title).length > 0) {
            project.title = title;
        }
        if (targetFunding > 0) {
            project.targetFunding = targetFunding;
        }
        if (startDate > 0) {
            project.startDate = startDate;
        }
        if (endDate > 0) {
            project.endDate = endDate;
        }
    }
}
