// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrowdfundingToken.sol";

interface ICrowdfunding {
    function getContributorsAndContributions(uint256 projectId) external view returns (address[] memory, uint256[] memory);
}

contract TokenBuilder {
    address private owner;
    address private crowdfundingContract;

    event TokenDeployed(address tokenAddress, uint256 projectId);
    event TokensDistributed(uint256 projectId, uint256 totalSupply);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address _crowdfundingContract) {
        owner = msg.sender;
        crowdfundingContract = _crowdfundingContract;
    }

    function deployTokenForProject(string memory name, string memory symbol, uint256 projectId, uint256 totalTokenSupply) external onlyOwner {
        CrowdfundingToken newToken = new CrowdfundingToken(name, symbol);
        distributeTokens(newToken, projectId, totalTokenSupply);
        emit TokenDeployed(address(newToken), projectId);
    }

    function distributeTokens(CrowdfundingToken token, uint256 projectId, uint256 totalTokenSupply) private {
        (address[] memory contributors, uint256[] memory contributions) = ICrowdfunding(crowdfundingContract).getContributorsAndContributions(projectId);
        
        uint256 totalFunds = 0;
        for (uint256 i = 0; i < contributions.length; i++) {
            totalFunds += contributions[i];
        }

        require(totalFunds > 0, "No contributions to distribute tokens against.");

        for (uint256 i = 0; i < contributors.length; i++) {
            uint256 tokensToMint = (contributions[i] * totalTokenSupply) / totalFunds;
            require(tokensToMint > 0, "Token amount to mint must be greater than 0");
            token.mint(contributors[i], tokensToMint);
        }

        emit TokensDistributed(projectId, totalTokenSupply);
    }

    function updateCrowdfundingContract(address _newCrowdfundingContract) external onlyOwner {
        require(_newCrowdfundingContract != address(0), "Invalid address.");
        crowdfundingContract = _newCrowdfundingContract;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address.");
        owner = newOwner;
    }
}
