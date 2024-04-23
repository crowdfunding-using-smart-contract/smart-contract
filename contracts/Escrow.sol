// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    IERC20 private _token;
    address private _crowdfundingContract;

    mapping(uint256 => mapping(address => uint256)) private _contributions;
    mapping(uint256 => uint256) private _projectTotalFunds;
    mapping(uint256 => address[]) private _projectContributors;

    event FundsHeld(uint256 indexed projectId, address indexed contributor, uint256 amount);
    event FundsReleasedToOwner(uint256 indexed projectId, uint256 amount);
    event RefundIssued(uint256 indexed projectId, address indexed contributor, uint256 amount);

    modifier onlyCrowdfundingContract() {
        require(msg.sender == _crowdfundingContract, "Caller is not the crowdfunding contract");
        _;
    }

    constructor(IERC20 tokenAddress, address initialOwner) Ownable(initialOwner) {
        _token = tokenAddress;
    }

    function setCrowdfundingContract(address crowdfundingContract) external onlyOwner {
        _crowdfundingContract = crowdfundingContract;
    }

    function holdFunds(uint256 projectId, address contributor, uint256 amount) external onlyCrowdfundingContract {
        require(_token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        
        if (_contributions[projectId][contributor] == 0) {
            _projectContributors[projectId].push(contributor);
        }

        _contributions[projectId][contributor] += amount;
        _projectTotalFunds[projectId] += amount;

        emit FundsHeld(projectId, contributor, amount);
    }

    function releaseFundsToOwner(uint256 projectId) external onlyCrowdfundingContract {
        uint256 totalFunds = _projectTotalFunds[projectId];
        require(totalFunds > 0, "No funds to release");

        _projectTotalFunds[projectId] = 0;
        require(_token.transfer(_crowdfundingContract, totalFunds), "Transfer to project owner failed");

        emit FundsReleasedToOwner(projectId, totalFunds);
    }

    function refundContributor(uint256 projectId, address contributor) external onlyCrowdfundingContract {
        uint256 contributedAmount = _contributions[projectId][contributor];
        require(contributedAmount > 0, "No contributions to refund");

        _contributions[projectId][contributor] = 0;
        require(_token.transfer(contributor, contributedAmount), "Refund failed");

        emit RefundIssued(projectId, contributor, contributedAmount);
    }

    function releaseFundsToContributors(uint256 projectId) external onlyCrowdfundingContract {
        require(_projectTotalFunds[projectId] > 0, "No funds to release");
        
        for (uint i = 0; i < _projectContributors[projectId].length; i++) {
            address contributor = _projectContributors[projectId][i];
            uint256 contributedAmount = _contributions[projectId][contributor];
            
            if (contributedAmount > 0) {
                _contributions[projectId][contributor] = 0;
                require(_token.transfer(contributor, contributedAmount), "Refund failed");
                emit RefundIssued(projectId, contributor, contributedAmount);
            }
        }
        
        _projectTotalFunds[projectId] = 0;
    }
}
