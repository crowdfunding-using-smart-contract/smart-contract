// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdfunding is Ownable {
    IERC20 private _token;

    constructor(IERC20 tokenAddress, address initialOwner) Ownable(initialOwner) {
        _token = tokenAddress;
    }

    struct Project {
        uint256 id;
        string title;
        string description;
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

    event ProjectCreated(uint256 indexed projectId, string title, address owner);
    event ContributionMade(uint256 indexed projectId, uint256 amount, address contributor);
    event ContributionRefunded(uint256 indexed projectId, address contributor);

    function createProject(
        string memory title,
        string memory description,
        uint256 targetFunding,
        uint256 startDate,
        uint256 endDate
    ) public {
        _projectIds++;
        uint256 newProjectId = _projectIds;

        projects[newProjectId] = Project({
            id: newProjectId,
            title: title,
            description: description,
            targetFunding: targetFunding,
            currentFunding: 0,
            startDate: startDate,
            endDate: endDate,
            owner: msg.sender,
            status: STATUS.ACTIVE
        });

        emit ProjectCreated(newProjectId, title, msg.sender);
    }

    function contribute(uint256 projectId, uint256 amount) public {
        emit ContributionMade(projectId, amount, msg.sender);
    }

    function refund(uint256 projectId) public {
        emit ContributionRefunded(projectId, msg.sender);
    }

    function deleteProject(uint256 projectId) public {
        require(msg.sender == projects[projectId].owner, "Only the owner can delete the project.");
        projects[projectId].status = STATUS.DELETED;
    }

    function getAllProjects(STATUS filterStatus) public view returns (uint256[] memory) {
        uint256 projectCount = _projectIds;
        uint256 filteredCount = 0;

        for (uint256 i = 1; i <= projectCount; i++) {
            if (projects[i].status == filterStatus) {
                filteredCount++;
            }
        }

        uint256[] memory filteredProjects = new uint256[](filteredCount);
        uint256 filteredIndex = 0;
        for (uint256 i = 1; i <= projectCount; i++) {
            if (projects[i].status == filterStatus) {
                filteredProjects[filteredIndex] = projects[i].id;
                filteredIndex++;
            }
        }

        return filteredProjects;
    }

    function getProject(uint256 projectId) public view returns (Project memory) {
        return projects[projectId];
    }

    function editProject(
        uint256 projectId,
        string memory title,
        string memory description,
        uint256 targetFunding,
        uint256 startDate,
        uint256 endDate
    ) public {
        require(msg.sender == projects[projectId].owner, "Only the owner can edit the project.");
        Project storage project = projects[projectId];

        if (bytes(title).length > 0) {
            project.title = title;
        }
        if (bytes(description).length > 0) {
            project.description = description;
        }
        if (targetFunding != 0) {
            project.targetFunding = targetFunding;
        }
        if (startDate != 0) {
            project.startDate = startDate;
        }
        if (endDate != 0) {
            project.endDate = endDate;
        }
    }
}
