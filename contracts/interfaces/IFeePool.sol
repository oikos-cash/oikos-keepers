//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IFeePool {

    // This struct represents the issuance activity that's happened in a fee period.
    struct FeePeriod {
        uint64 feePeriodId;
        uint64 startingDebtIndex;
        uint64 startTime;
        uint feesToDistribute;
        uint feesClaimed;
        uint rewardsToDistribute;
        uint rewardsClaimed;
    }
 
    // Views
    function getExchangeFeeRateForSynth(bytes32 synthKey) external view returns (uint);

    // solhint-disable-next-line func-name-mixedcase
    function FEE_ADDRESS() external view returns (address);

    function feesAvailable(address account) external view returns (uint, uint);

    function isFeesClaimable(address account) external view returns (bool);

    function totalFeesAvailable() external view returns (uint);

    function lastFeePeriodStartTime() external view returns (uint);

    function totalRewardsAvailable() external view returns (uint);

    // Mutative Functions
    function claimFees() external returns (bool);

    function claimOnBehalf(address claimingForAddress) external returns (bool);

    function closeCurrentFeePeriod() external;

    // Restricted: used internally to Oikos
    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex
    ) external;

    function recordFeePaid(uint oUSDAmount) external;

    function setRewardsToDistribute(uint amount) external;
}
