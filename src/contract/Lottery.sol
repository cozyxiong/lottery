// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./LotteryStorage.sol";
import "../interface/ILottery.sol";

contract Lottery is Initializable, OwnableUpgradeable, ILottery, LotteryStorage {

    using SafeERC20 for IERC20;
    IERC20 public tokenAddress;

    error NotEnoughToken(address tokenAddress, address purchaser);
    error DrawTimeNotReached(uint256 nowTime, uint256 drawTime);
    error RoundSeedTooLarge(uint256 limit);

    event lotteryPurchaseInfo(address purchaser, uint256 roundNumber);
    event LotteryDraw(uint256 roundNumber, address winner, uint256 rewardAmount, uint256 middleFee);

    constructor(){
        _disableInitializers();
    }

    function initialize(address _owner, IERC20 _tokenAddress) public initializer {
        __Ownable_init(_owner);

        roundNumber = 1;
        roundAmount = 0;
        drawTime[roundNumber] = block.timestamp + drawTimeInterval;
        tokenAddress = _tokenAddress;
    }

    function purchaseLotteryTicket(address purchaser) external {
        if (tokenAddress.balanceOf(purchaser) < lotteryAmount) {
            revert NotEnoughToken(address(tokenAddress), purchaser);
        }

        tokenAddress.safeTransferFrom(purchaser, address(this), lotteryAmount);
        if (lotteryRound[roundNumber].totalAmount <= 0) {
            LotteryRoundInfo memory info = LotteryRoundInfo({
                totalAmount: lotteryAmount,
                status: true,
                winner: address(0)
            });
            lotteryRound[roundNumber] = info;
        } else {
            lotteryRound[roundNumber].totalAmount += lotteryAmount;
        }
        lotteryParticipant[roundNumber].push(purchaser);

        emit lotteryPurchaseInfo(purchaser, roundNumber);
    }

    function lotteryDraw(uint256 roundSeed) external onlyOwner {
        if (block.timestamp < drawTime[roundNumber]) {
            revert DrawTimeNotReached(block.timestamp, drawTime[roundNumber]);
        }

        address[] memory participant = lotteryParticipant[roundNumber];
        if (roundSeed > participant.length) {
            revert RoundSeedTooLarge(participant.length);
        }

        address winner = participant[roundSeed];
        uint256 rewardAmount = (lotteryRound[roundNumber].totalAmount * 95) / 100;
        uint256 middleFee = lotteryRound[roundNumber].totalAmount - rewardAmount;
        tokenAddress.safeTransferFrom(address(this), winner, rewardAmount);
        tokenAddress.safeTransferFrom(address(this), owner(), middleFee);

        emit LotteryDraw(roundNumber, winner, rewardAmount, middleFee);

        roundNumber++;
        drawTime[roundNumber] = block.timestamp + drawTimeInterval;
    }

    function getLotteryRoundInfo(uint256 roundNumber) view external returns (LotteryRoundInfo memory) {
        return lotteryRound[roundNumber];
    }
}
