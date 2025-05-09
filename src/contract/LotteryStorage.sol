// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract LotteryStorage {
    struct LotteryRoundInfo {
        uint256 totalAmount;
        bool status;
        address winner;
    }
    uint256 public roundNumber;
    uint256 public constant lotteryAmount = 10e6;
    uint256 public roundAmount;
    uint32 public constant drawTimeInterval = 7 days;
    mapping(uint256 => uint256) public drawTime;
    mapping(uint256 => LotteryRoundInfo) public lotteryRound;
    mapping(uint256 => address[]) public lotteryParticipant;

}
