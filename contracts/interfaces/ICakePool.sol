pragma solidity ^0.8.0;

interface ICakePool {
     function notifyRewardAmount(uint256 reward) external ;
     function setRewardDistribution(address _rewardDistribution) external;
}
