// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../contract/LotteryStorage.sol";

interface ILottery {
    function purchaseLotteryTicket(address purchaser) external;
    function lotteryDraw(uint256 roundSeed) external;
    function getLotteryRoundInfo(uint256 roundNumber) view external returns (LotteryStorage.LotteryRoundInfo memory);
}
