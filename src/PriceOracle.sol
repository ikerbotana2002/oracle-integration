// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";

contract PriceOracle {
    uint8 public constant TARGET_DECIMALS = 18;

    AggregatorV3Interface public immutable priceFeed;
    uint8 public immutable feedDecimals;

    error InvalidPriceFeed();
    error UnsupportedDecimals();
    error InvalidPrice();

    constructor(address priceFeed_) {
        if (priceFeed_ == address(0) || priceFeed_.code.length == 0) {
            revert InvalidPriceFeed();
        }

        priceFeed = AggregatorV3Interface(priceFeed_);

        uint8 decimals_ = priceFeed.decimals();

        if (decimals_ > TARGET_DECIMALS) {
            revert UnsupportedDecimals();
        }

        feedDecimals = decimals_;
    }

    function getPrice18() external view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();

        if (answer <= 0) {
            revert InvalidPrice();
        }

        uint256 multiplier = 10 ** uint256(TARGET_DECIMALS - feedDecimals);

        return uint256(answer) * multiplier;
    }
}
