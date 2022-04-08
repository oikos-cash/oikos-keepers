//SPDX-License-Identifier: MIT
pragma solidity >=0.6.7;

import "./interfaces/ICakePool.sol";
import "@chainlink/contracts/src/v0.6/interfaces/KeeperCompatibleInterface.sol";

contract RewardsRecharger is KeeperCompatibleInterface, ICakePool {
   
    address public derive_oUSD_rewards_contract      = 0x8559aef12e2c40e66f0eb600d0dd8ae5cea419d7;
    address public pancake_oUSD_BNB_rewards_contract = 0xd8f27e3e7da60d8cf43b76e335412369fed96295;
    address public derive_DRV_rewards_contract       = 0x0555746f7104DB313660c09E38bF8a1dbdcd3681;

    uint public derive_oUSD_rewards_amount = 100000 ether;
    uint public pancake_oUSD_BNB_rewards_amount = 100000 ether;
    uint public derive_DRV_rewards_amount = 300000 ether;

    /* ---------- Constructor ---------- */
    constructor(uint256 updateInterval) public {
        owner = msg.sender;
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
    }

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        ICakePool(derive_oUSD_rewards_contract).notifyRewardAmount(derive_oUSD_rewards_amount);
        ICakePool(pancake_oUSD_BNB_rewards_contract).notifyRewardAmount(pancake_oUSD_BNB_rewards_amount);
        ICakePool(derive_DRV_rewards_contract).notifyRewardAmount(derive_DRV_rewards_amount);
        lastTimeStamp = block.timestamp;
    }

}