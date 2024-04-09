// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockCrowdfunding {
    struct Project {
        uint256 id;
        string title;
        uint256 targetFunding;
        uint256 currentFunding;
        uint256 startDate;
        uint256 endDate;
        address owner;
        STATUS status;
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
    event ContributionRefunded(uint256 indexed projectId, uint256 amount, address contributor);

    function createProject(
        string memory title,
        uint256 targetFunding,
        uint256 startDate,
        uint256 endDate
    ) public {
        _projectIds++;
        uint256 newProjectId = _projectIds;

        projects[newProjectId] = Project({
            id: newProjectId,
            title: title,
            targetFunding: targetFunding,
            currentFunding: 0,
            startDate: startDate,
            endDate: endDate,
            owner: msg.sender,
            status: STATUS.ACTIVE
        });

        emit ProjectCreated(newProjectId, title, msg.sender);
    }

    function deleteProject(uint256 projectId) public {
        require(msg.sender == projects[projectId].owner, "Only the owner can delete the project.");
        projects[projectId].status = STATUS.DELETED;
    }

    function getAllProjects() public view returns (uint256[] memory) {
        uint256 projectCount = _projectIds;

        uint256[] memory filteredProjects = new uint256[](projectCount);
        uint256 filteredIndex = 0;
        for (uint256 i = 1; i <= projectCount; i++) {
            filteredProjects[filteredIndex] = projects[i].id;
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
