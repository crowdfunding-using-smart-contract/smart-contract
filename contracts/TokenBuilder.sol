// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowdfundingToken.sol";

contract TokenBuilder {
    address private owner;
    address private crowdfundingContract;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address _crowdfundingContract) {
        owner = msg.sender;
        crowdfundingContract = _crowdfundingContract;
    }

    function deployTokenForProject(string memory name, string memory symbol, uint256 projectId) external onlyOwner {
        CrowdfundingToken newToken = new CrowdfundingToken(name, symbol);
        distributeTokens(newToken, projectId);
    }

    function distributeTokens(CrowdfundingToken token, uint256 projectId) private {
        // Assuming a function in Crowdfunding contract that returns a list of contributors and their contributions for a given projectId
        // (address[] memory contributors, uint256[] memory contributions) = Crowdfunding(crowdfundingContract).getContributorsAndContributions(projectId);

        // uint256 totalFunds = 0;
        // for (uint256 i = 0; i < contributions.length; i++) {
        //     totalFunds += contributions[i];
        // }

        // for (uint256 i = 0; i < contributors.length; i++) {
        //     uint256 tokensToMint = (contributions[i] * totalTokenSupply) / totalFunds;
        //     token.mint(contributors[i], tokensToMint);
        // }
    }
}
