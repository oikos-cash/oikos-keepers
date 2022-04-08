pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

interface IOikos {
    // ========== PUBLIC STATE VARIABLES ==========
    function mint() external returns (bool);
}

interface IFeePool {
    function closeCurrentFeePeriod() external;
}

contract MintAndCloseFeePeriod is KeeperCompatibleInterface {
    // Oikos ERC20Proxy on BSC mainnet
    address public constant oikos = 0x18aCf236eB40c0d4824Fb8f2582EBbEcD325Ef6a;
    IFeePool public constant feePool = IFeePool(0x3cFAa9FC30F6277990A96E9d11c1207dbf0d654C);

    uint public interval = 604800; // 1 week
    uint public lastTimestamp = block.timestamp;

    function mintAndCloseFeePeriod() internal {
        IOikos(oikos).mint();
        feePool.closeCurrentFeePeriod();
        // forward mint reward
        IERC20 oks = IERC20(oikos);
        oks.transfer(msg.sender, oks.balanceOf(address(this)));
    }

    //Called by Chainlink Keepers to check if work needs to be done
    function checkUpkeep(
        bytes calldata /*checkData */
    ) external override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimestamp) > interval;
    }

    //Called by Chainlink Keepers to handle work
    function performUpkeep(bytes calldata) external override {
        mintAndCloseFeePeriod();
        lastTimestamp = block.timestamp;
    }

}