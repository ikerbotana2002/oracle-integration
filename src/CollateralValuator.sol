// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SecurePriceOracle} from "./SecurePriceOracle.sol";

contract CollateralValuator {
    uint256 public constant PRECISION = 1e18;
    uint256 public constant BPS = 10_000;
    uint256 public constant MAX_LTV_BPS = 5_000;

    SecurePriceOracle public immutable oracle;

    error InvalidOracle();
    error AmountOverflow();

    constructor(address oracle_) {
        if (oracle_ == address(0) || oracle_.code.length == 0) {
            revert InvalidOracle();
        }

        oracle = SecurePriceOracle(oracle_);
    }

    // Devuelve el valor en USD de una cantidad de ETH.
    // Tanto ethAmount como el resultado usan 18 decimales.
    function getCollateralValueUsd18(uint256 ethAmount) public view returns (uint256) {
        uint256 price18 = oracle.getPrice18();

        if (ethAmount > type(uint256).max / price18) {
            revert AmountOverflow();
        }

        return (ethAmount * price18) / PRECISION;
    }

    // Calcula el prestamo maximo segun un LTV del 50%.
    function getMaxBorrowUsd18(uint256 ethAmount) public view returns (uint256) {
        uint256 collateralValue = getCollateralValueUsd18(ethAmount);

        return (collateralValue / BPS * MAX_LTV_BPS + (collateralValue % BPS) * MAX_LTV_BPS / BPS);
    }

    // Comprueba si una cantidad solicitada cumple el LTV.
    function isBorrowAllowed(uint256 ethAmount, uint256 borrowUsd18) external view returns (bool) {
        uint256 maxBorrow = getMaxBorrowUsd18(ethAmount);

        return borrowUsd18 <= maxBorrow;
    }
}
