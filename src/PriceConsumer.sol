// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";

contract PriceConsumer {
    AggregatorV3Interface public immutable priceFeed;

    error InvalidPriceFeed();

    constructor(address priceFeed_) {
        if (priceFeed_ == address(0) || priceFeed_.code.length == 0) {
            revert InvalidPriceFeed();
        }

        priceFeed = AggregatorV3Interface(priceFeed_);
    }

    function getLatestPrice() external view returns (int256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();

        return answer;
    }

    function getPriceDecimals() external view returns (uint8) {
        return priceFeed.decimals();
    }

    function getPriceDetails() external view returns (int256 price, uint8 decimals_, uint256 updatedAt) {
        (, int256 answer,, uint256 timestamp,) = priceFeed.latestRoundData();

        return (answer, priceFeed.decimals(), timestamp);
    }
}
