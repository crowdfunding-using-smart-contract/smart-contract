// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    IERC20 private _token;
    address private _crowdfundingContract;

    constructor(IERC20 tokenAddress, address initialOwner) Ownable(initialOwner) {
        _token = tokenAddress;
    }

    mapping(uint256 => address) private _projectOwners;
    mapping(uint256 => mapping(address => uint256)) private _contributions;

    event FundsHeld(uint256 indexed projectId, address indexed contributor, uint256 amount);
    event FundsReleasedToOwner(uint256 indexed projectId, uint256 amount);
    event RefundIssued(uint256 indexed projectId, address indexed contributor, uint256 amount);

    modifier onlyCrowdfundingContract() {
        require(msg.sender == _crowdfundingContract, "Caller is not the crowdfunding contract");
        _;
    }

    function setCrowdfundingContract(address crowdfundingContract) external onlyOwner {
        _crowdfundingContract = crowdfundingContract;
    }

    function holdFunds(uint256 projectId, address contributor, uint256 amount) external onlyCrowdfundingContract {
        require(_token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        _contributions[projectId][contributor] += amount;
        emit FundsHeld(projectId, contributor, amount);
    }

    function setProjectOwner(uint256 projectId, address owner) external onlyCrowdfundingContract {
        _projectOwners[projectId] = owner;
    }

    function releaseFundsToOwner(uint256 projectId) external onlyCrowdfundingContract {
        address projectOwner = _projectOwners[projectId];
        require(projectOwner != address(0), "Project owner not set");

        uint256 totalFunds = _token.balanceOf(address(this));
        require(_token.transfer(projectOwner, totalFunds), "Transfer to project owner failed");

        emit FundsReleasedToOwner(projectId, totalFunds);
    }

    function refundContributor(uint256 projectId, address contributor) external onlyCrowdfundingContract {
        uint256 contributedAmount = _contributions[projectId][contributor];
        require(contributedAmount > 0, "No contributions to refund");

        _contributions[projectId][contributor] = 0;
        require(_token.transfer(contributor, contributedAmount), "Refund failed");

        emit RefundIssued(projectId, contributor, contributedAmount);
    }
}
