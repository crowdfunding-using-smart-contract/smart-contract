// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// // import "./Token.sol";

// contract Crowdfunding is ReentrancyGuard, Ownable {
//     using Counters for Counters.Counter;
//     Counters.Counter private _projectIds;

//     struct Project {
//         uint256 id;
//         string title;
//         string subTitle;
//         string description;
//         string categoryID;
//         string subCategoryID;
//         string location;
//         uint256 targetFunding;
//         uint256 currentFunding;
//         uint256 startDate;
//         uint256 endDate;
//         uint256 launchDate;
//         address owner;
//         bool isFunded;
//         STATUS status;
//     }

//     enum STATUS {
//         ACTIVE,
//         DELETED,
//         SUCCESSFUL,
//         UNSUCCESSFUL
//     }

//     mapping(uint256 => Project) public projects;

//     event ProjectCreated(
//         uint256 indexed projectId,
//         string title,
//         address owner
//     );

//     function createProject(
//         string memory title,
//         string memory subTitle,
//         string memory description,
//         string memory categoryID,
//         string memory subCategoryID,
//         string memory location,
//         uint256 targetFunding,
//         uint256 startDate,
//         uint256 endDate,
//         uint256 launchDate
//     ) public {
//         _projectIds.increment();
//         uint256 newProjectId = _projectIds.current();

//         projects[newProjectId] = Project({
//             id: newProjectId,
//             title: title,
//             subTitle: subTitle,
//             description: description,
//             categoryID: categoryID,
//             subCategoryID: subCategoryID,
//             location: location,
//             targetFunding: targetFunding,
//             currentFunding: 0,
//             startDate: startDate,
//             endDate: endDate,
//             launchDate: launchDate,
//             owner: msg.sender,
//             isFunded: false,
//             status: STATUS.ACTIVE
//         });

//         emit ProjectCreated(newProjectId, title, msg.sender);
//     }

//     // function contribute(uint256 projectId, uint256 amount) public {}

//     // function refund(uint256 projectId) public {}

//     function deleteProject(uint256 projectId) public {
//         require(msg.sender == projects[projectId].owner, "Only the owner can delete the project.");
//         projects[projectId].status = STATUS.DELETED;
//     }

//     function getAllProjects(STATUS filterStatus) public view returns (uint256[] memory) {
//         uint256 projectCount = _projectIds.current();
//         uint256 filteredCount = 0;

//         for (uint256 i = 1; i <= projectCount; i++) {
//             if (projects[i].status == filterStatus) {
//                 filteredCount++;
//             }
//         }

//         uint256[] memory filteredProjects = new uint256[](filteredCount);
//         uint256 filteredIndex = 0;
//         for (uint256 i = 1; i <= projectCount; i++) {
//             if (projects[i].status == filterStatus) {
//                 filteredProjects[filteredIndex] = projects[i].id;
//                 filteredIndex++;
//             }
//         }

//         return filteredProjects;
//     }

//     function getProject(uint256 projectId) public view returns (Project memory) {
//         return projects[projectId];
//     }

//     function editProject(
//         uint256 projectId,
//         string memory title,
//         string memory subTitle,
//         string memory description,
//         string memory categoryID,
//         string memory subCategoryID,
//         string memory location,
//         uint256 targetFunding,
//         uint256 startDate,
//         uint256 endDate,
//         uint256 launchDate
//     ) public {
//         require(msg.sender == projects[projectId].owner, "Only the owner can edit the project.");
//         Project storage project = projects[projectId];

//         // Check for non-empty strings and non-sentinel values before updating
//         if (bytes(title).length > 0) {
//             project.title = title;
//         }
//         if (bytes(subTitle).length > 0) {
//             project.subTitle = subTitle;
//         }
//         if (bytes(description).length > 0) {
//             project.description = description;
//         }
//         if (bytes(categoryID).length > 0) {
//             project.categoryID = categoryID;
//         }
//         if (bytes(subCategoryID).length > 0) {
//             project.subCategoryID = subCategoryID;
//         }
//         if (bytes(location).length > 0) {
//             project.location = location;
//         }
//         if (targetFunding != 0) {
//             project.targetFunding = targetFunding;
//         }
//         if (startDate != 0) {
//             project.startDate = startDate;
//         }
//         if (endDate != 0) {
//             project.endDate = endDate;
//         }
//         if (launchDate != 0) {
//             project.launchDate = launchDate;
//         }
//     }

// }
