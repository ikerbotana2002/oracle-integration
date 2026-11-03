// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "../../src/interfaces/AggregatorV3Interface.sol";

contract AdversarialPriceFeed is AggregatorV3Interface {
    uint8 public immutable override decimals;

    int256 public answer;
    uint256 public updatedAt;
    bool public shouldRevert;

    constructor(uint8 decimals_) {
        decimals = decimals_;
    }

    function setData(int256 answer_, uint256 updatedAt_) external {
        answer = answer_;
        updatedAt = updatedAt_;
    }

    function setShouldRevert(bool value) external {
        shouldRevert = value;
    }

    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        require(!shouldRevert, "Feed unavailable");

        return (1, answer, updatedAt, updatedAt, 1);
    }
}
