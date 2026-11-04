// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CollateralValuator} from "../src/CollateralValuator.sol";
import {SecurePriceOracle} from "../src/SecurePriceOracle.sol";
import {AdversarialPriceFeed} from "./mocks/AdversarialPriceFeed.sol";

contract CollateralValuatorTest is Test {
    AdversarialPriceFeed feed;
    SecurePriceOracle oracle;
    CollateralValuator valuator;

    uint256 constant MAX_AGE = 1 hours;

    function setUp() public {
        vm.warp(1_000_000);

        feed = new AdversarialPriceFeed(8);
        feed.setData(3000e8, block.timestamp);

        oracle = new SecurePriceOracle(address(feed), MAX_AGE);

        valuator = new CollateralValuator(address(oracle));
    }

    // 1. Dos ETH valen 6000 USD.
    function testCalculatesCollateralValue() public view {
        assertEq(valuator.getCollateralValueUsd18(2 ether), 6000 ether);
    }

    // 2. Admite cantidades fraccionarias de ETH.
    function testCalculatesFractionalETH() public view {
        assertEq(valuator.getCollateralValueUsd18(0.5 ether), 1500 ether);
    }

    // 3. El LTV maximo es del 50%.
    function testCalculatesMaxBorrow() public view {
        assertEq(valuator.getMaxBorrowUsd18(2 ether), 3000 ether);
    }

    // 4. El importe exacto del limite se admite.
    function testAllowsBorrowAtLimit() public view {
        assertTrue(valuator.isBorrowAllowed(2 ether, 3000 ether));
    }

    // 5. No permite superar el LTV.
    function testRejectsBorrowAboveLimit() public view {
        assertFalse(valuator.isBorrowAllowed(2 ether, 3001 ether));
    }

    // 6. Si ETH cae, el maximo tambien cae.
    function testPriceDropReducesBorrowingCapacity() public {
        assertEq(valuator.getMaxBorrowUsd18(2 ether), 3000 ether);

        feed.setData(1500e8, block.timestamp);

        assertEq(valuator.getMaxBorrowUsd18(2 ether), 1500 ether);

        assertFalse(valuator.isBorrowAllowed(2 ether, 3000 ether));
    }

    // 7. Rechaza los precios obsoletos.
    function testRevertsWhenPriceIsStale() public {
        vm.warp(block.timestamp + MAX_AGE + 1);

        vm.expectRevert(SecurePriceOracle.StalePrice.selector);

        valuator.getCollateralValueUsd18(2 ether);
    }

    // 8. Rechaza precios de cero.
    function testRevertsWhenPriceIsZero() public {
        feed.setData(0, block.timestamp);

        vm.expectRevert(SecurePriceOracle.InvalidPrice.selector);

        valuator.getCollateralValueUsd18(2 ether);
    }

    // 9. No acepta una direccion sin contrato.
    function testRejectsInvalidOracle() public {
        vm.expectRevert(CollateralValuator.InvalidOracle.selector);

        new CollateralValuator(address(0));
    }

    // 10. Propiedad fuzz: valoracion proporcional.
    function testFuzzCollateralValue(uint256 ethAmount) public view {
        // El precio simulado es 3000 USD/ETH.
        // Limite de cantidades para este escenario.
        ethAmount = bound(ethAmount, 0, 100_000 ether);

        uint256 expected = ethAmount * 3000;

        assertEq(valuator.getCollateralValueUsd18(ethAmount), expected);
    }

    // 11. La lectura tambien rechaza fallos del feed.
    function testRevertsWhenFeedUnavailable() public {
        feed.setShouldRevert(true);

        vm.expectRevert(abi.encodeWithSignature("Error(string)", "Feed unavailable"));

        valuator.getMaxBorrowUsd18(2 ether);
    }
}
