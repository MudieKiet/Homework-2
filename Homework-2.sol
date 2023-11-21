// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedCrowdfunding is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public fundingToken;

    uint256 public goalAmount;
    uint256 public deadline;
    uint256 public totalFunds;

    mapping(address => uint256) public contributions;
    bool public campaignEnded;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event CampaignEnded(bool success);

    modifier onlyBeforeDeadline() {
        require(block.timestamp < deadline, "Campaign has ended");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp >= deadline, "Campaign has not ended");
        _;
    }

    modifier campaignNotEnded() {
        require(!campaignEnded, "Campaign has already ended");
        _;
    }

    constructor(address _fundingToken, uint256 _goalAmount, uint256 _durationInDays) {
        require(_fundingToken != address(0), "Invalid token address");
        require(_goalAmount > 0, "Goal amount must be greater than 0");
        require(_durationInDays > 0, "Campaign duration must be greater than 0");

        fundingToken = IERC20(_fundingToken);
        goalAmount = _goalAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
        campaignEnded = false;
    }
function contribute(uint256 _amount) external onlyBeforeDeadline campaignNotEnded {
        require(_amount > 0, "Contribution amount must be greater than 0");

        // Transfer funds from the contributor to the contract
        fundingToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Update contributor's contribution amount
        contributions[msg.sender] += _amount;

        // Update total funds raised
        totalFunds += _amount;

        emit ContributionReceived(msg.sender, _amount);
    }
  
}
