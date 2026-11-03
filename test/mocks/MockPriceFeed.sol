// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "../../src/interfaces/AggregatorV3Interface.sol";

contract MockPriceFeed is AggregatorV3Interface {
    uint8 private immutable feedDecimals;

    int256 private currentAnswer;
    uint256 private lastUpdated;
    uint80 private currentRoundId;

    constructor(uint8 decimals_, int256 initialAnswer) {
        feedDecimals = decimals_;
        currentAnswer = initialAnswer;
        lastUpdated = block.timestamp;
        currentRoundId = 1;
    }

    function decimals() external view returns (uint8) {
        return feedDecimals;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (currentRoundId, currentAnswer, lastUpdated, lastUpdated, currentRoundId);
    }

    function updateAnswer(int256 newAnswer) external {
        currentAnswer = newAnswer;
        lastUpdated = block.timestamp;
        currentRoundId++;
    }
}
