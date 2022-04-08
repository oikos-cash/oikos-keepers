//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "./CakePool.sol";
import "./Ownable.sol";

 
contract RewardsRecharger is KeeperCompatibleInterface, Ownable, CakePool {
   
    address public derive_oUSD_rewards_contract      = 0x8559AeF12e2C40E66f0eb600d0Dd8ae5CeA419D7;
    address public pancake_oUSD_BNB_rewards_contract = 0xD8f27e3e7da60d8CF43b76e335412369FEd96295;
    address public derive_DRV_rewards_contract       = 0x0555746f7104DB313660c09E38bF8a1dbdcd3681;

    uint public derive_oUSD_rewards_amount = 100000 ether;
    uint public pancake_oUSD_BNB_rewards_amount = 100000 ether;
    uint public derive_DRV_rewards_amount = 300000 ether;

    uint public interval;
    uint public lastTimestamp;

    CakePool public derivePool_oUSD ;
    CakePool public pancakePool_oUSD_BNB ;
    CakePool public derivePool_DRV;

    /* ---------- Constructor ---------- */
    constructor(uint256 updateInterval) public Ownable() {
        interval = updateInterval;
        lastTimestamp = block.timestamp;
        derivePool_oUSD = CakePool(derive_oUSD_rewards_contract);
        pancakePool_oUSD_BNB = CakePool(pancake_oUSD_BNB_rewards_contract);
        derivePool_DRV = CakePool(derive_DRV_rewards_contract);
    }

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimestamp) > interval;
    }

    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        derivePool_oUSD.notifyRewardAmount(derive_oUSD_rewards_amount);
        pancakePool_oUSD_BNB.notifyRewardAmount(pancake_oUSD_BNB_rewards_amount);
        derivePool_DRV.notifyRewardAmount(derive_DRV_rewards_amount);
        lastTimestamp = block.timestamp;
    }

}