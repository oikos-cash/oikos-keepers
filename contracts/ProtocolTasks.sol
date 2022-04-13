pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IFeePool.sol";
import "./interfaces/ICakePool.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

interface IOikos {
    function mint() external returns (bool);
}




contract ProtocolTasks is KeeperCompatibleInterface {

    // Oikos ERC20Proxy on BSC mainnet
    address public constant oikos = 0x18aCf236eB40c0d4824Fb8f2582EBbEcD325Ef6a;
    IFeePool public constant feePool = IFeePool(0x3cFAa9FC30F6277990A96E9d11c1207dbf0d654C);

    uint public interval = 604800; // 1 week
   
    address public derive_oUSD_rewards_contract      = 0x8559AeF12e2C40E66f0eb600d0Dd8ae5CeA419D7;
    address public derive_DRV_rewards_contract       = 0x0555746f7104DB313660c09E38bF8a1dbdcd3681;
    address public pancake_oUSD_BNB_rewards_contract = 0xD8f27e3e7da60d8CF43b76e335412369FEd96295;

    uint public derive_oUSD_rewards_amount      = 100000 ether;
    uint public pancake_oUSD_BNB_rewards_amount = 100000 ether;
    uint public derive_DRV_rewards_amount       = 300000 ether;

    ICakePool public derivePool_oUSD      = ICakePool(derive_oUSD_rewards_contract);
    ICakePool public derivePool_DRV       = ICakePool(derive_DRV_rewards_contract);
    ICakePool public pancakePool_oUSD_BNB = ICakePool(pancake_oUSD_BNB_rewards_contract);

    function mintAndCloseFeePeriod() internal {

        IOikos(oikos).mint();
        feePool.closeCurrentFeePeriod();
        
        // forward mint reward
        IERC20 oks = IERC20(oikos);
        oks.transfer(msg.sender, oks.balanceOf(address(this)));

        //notify reward amounts
        notifyRewardAmounts();
    }

    //Notify reward amounts
    function notifyRewardAmounts() internal {
        derivePool_oUSD.notifyRewardAmount(derive_oUSD_rewards_amount);
        pancakePool_oUSD_BNB.notifyRewardAmount(pancake_oUSD_BNB_rewards_amount);
        derivePool_DRV.notifyRewardAmount(derive_DRV_rewards_amount);
    }

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata
    ) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = true;
    }

    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        mintAndCloseFeePeriod();
    }

}