//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";


interface ICakePool {
     function notifyRewardAmount(uint256 reward) external ;
}
 
contract RewardsRecharger is KeeperCompatibleInterface {
   
    address public derive_oUSD_rewards_contract      = 0x8559AeF12e2C40E66f0eb600d0Dd8ae5CeA419D7;
    address public derive_DRV_rewards_contract       = 0x0555746f7104DB313660c09E38bF8a1dbdcd3681;
    address public pancake_oUSD_BNB_rewards_contract = 0xD8f27e3e7da60d8CF43b76e335412369FEd96295;

    uint public derive_oUSD_rewards_amount      = 100000 ether;
    uint public pancake_oUSD_BNB_rewards_amount = 100000 ether;
    uint public derive_DRV_rewards_amount       = 300000 ether;

    uint public interval = 604800; // 1 week
    uint public lastTimestamp = block.timestamp;

    ICakePool public derivePool_oUSD      = ICakePool(derive_oUSD_rewards_contract);
    ICakePool public derivePool_DRV       = ICakePool(derive_DRV_rewards_contract);
    ICakePool public pancakePool_oUSD_BNB = ICakePool(pancake_oUSD_BNB_rewards_contract);

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata 
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimestamp) >= interval;
    }

    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        derivePool_oUSD.notifyRewardAmount(derive_oUSD_rewards_amount);
        pancakePool_oUSD_BNB.notifyRewardAmount(pancake_oUSD_BNB_rewards_amount);
        derivePool_DRV.notifyRewardAmount(derive_DRV_rewards_amount);
        lastTimestamp = block.timestamp;
    }

}