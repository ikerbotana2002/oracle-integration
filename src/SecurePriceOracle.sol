// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";

contract SecurePriceOracle {
    uint8 public constant TARGET_DECIMALS = 18;

    AggregatorV3Interface public immutable priceFeed;
    uint8 public immutable feedDecimals;
    uint256 public immutable maxAge;

    error InvalidPriceFeed();
    error InvalidMaxAge();
    error UnsupportedDecimals();
    error InvalidPrice();
    error InvalidTimestamp();
    error StalePrice();
    error PriceOverflow();

    constructor(address feed_, uint256 maxAge_) {
        if (feed_ == address(0) || feed_.code.length == 0) {
            revert InvalidPriceFeed();
        }

        if (maxAge_ == 0) {
            revert InvalidMaxAge();
        }

        priceFeed = AggregatorV3Interface(feed_);
        maxAge = maxAge_;

        uint8 decimals_ = priceFeed.decimals();

        if (decimals_ > TARGET_DECIMALS) {
            revert UnsupportedDecimals();
        }

        feedDecimals = decimals_;
    }

    function getPrice18() external view returns (uint256) {
        (, int256 answer,, uint256 updatedAt,) = priceFeed.latestRoundData();

        // 1. El precio debe ser positivo.
        if (answer <= 0) {
            revert InvalidPrice();
        }

        // 2. La fecha debe ser valida.
        if (updatedAt == 0 || updatedAt > block.timestamp) {
            revert InvalidTimestamp();
        }

        // 3. No aceptar datos demasiado antiguos.
        if (block.timestamp - updatedAt > maxAge) {
            revert StalePrice();
        }

        // 4. Normalizar a 18 decimales.
        uint256 multiplier = 10 ** uint256(TARGET_DECIMALS - feedDecimals);

        uint256 price = uint256(answer);

        // Evitar overflow en la multiplicacion.
        if (price > type(uint256).max / multiplier) {
            revert PriceOverflow();
        }

        return price * multiplier;
    }
}
