// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {SecurePriceOracle} from "../src/SecurePriceOracle.sol";

import {AdversarialPriceFeed} from "./mocks/AdversarialPriceFeed.sol";

contract SecurePriceOracleTest is Test {
    AdversarialPriceFeed feed;
    SecurePriceOracle oracle;

    uint256 constant MAX_AGE = 1 hours;

    function setUp() public {
        // Una fecha de prueba estable y positiva.
        vm.warp(1_000_000);

        feed = new AdversarialPriceFeed(8);
        feed.setData(3000e8, block.timestamp);

        oracle = new SecurePriceOracle(address(feed), MAX_AGE);
    }

    // 1. El precio valido funciona.
    function testAcceptsFreshPrice() public view {
        assertEq(oracle.getPrice18(), 3000 ether);
    }

    // 2. Acepta un precio dentro del limite.
    function testAcceptsPriceAtAgeLimit() public {
        vm.warp(block.timestamp + MAX_AGE);

        assertEq(oracle.getPrice18(), 3000 ether);
    }

    // 3. Rechaza el precio al superar el limite.
    function testRejectsStalePrice() public {
        vm.warp(block.timestamp + MAX_AGE + 1);

        vm.expectRevert(SecurePriceOracle.StalePrice.selector);

        oracle.getPrice18();
    }

    // 4. No acepta timestamps inexistentes.
    function testRejectsZeroTimestamp() public {
        feed.setData(3000e8, 0);

        vm.expectRevert(SecurePriceOracle.InvalidTimestamp.selector);

        oracle.getPrice18();
    }

    // 5. No acepta fechas futuras.
    function testRejectsFutureTimestamp() public {
        feed.setData(3000e8, block.timestamp + 100);

        vm.expectRevert(SecurePriceOracle.InvalidTimestamp.selector);

        oracle.getPrice18();
    }

    // 6. No acepta precios negativos.
    function testRejectsNegativePrice() public {
        feed.setData(-3000e8, block.timestamp);

        vm.expectRevert(SecurePriceOracle.InvalidPrice.selector);

        oracle.getPrice18();
    }

    // 7. No acepta precios cero.
    function testRejectsZeroPrice() public {
        feed.setData(0, block.timestamp);

        vm.expectRevert(SecurePriceOracle.InvalidPrice.selector);

        oracle.getPrice18();
    }

    // 8. Si el oraculo falla, la lectura falla.
    function testPropagatesFeedFailure() public {
        feed.setShouldRevert(true);

        vm.expectRevert(bytes("Feed unavailable"));

        oracle.getPrice18();
    }

    // 9. No permite una antiguedad maxima cero.
    function testRejectsZeroMaxAge() public {
        vm.expectRevert(SecurePriceOracle.InvalidMaxAge.selector);

        new SecurePriceOracle(address(feed), 0);
    }

    // 10. Detecta overflow al normalizar.
    function testRejectsPriceOverflow() public {
        feed.setData(type(int256).max, block.timestamp);

        vm.expectRevert(SecurePriceOracle.PriceOverflow.selector);

        oracle.getPrice18();
    }

    // 11. Un nuevo precio valido vuelve a funcionar.
    function testAcceptsUpdatedPriceAfterStaleData() public {
        vm.warp(block.timestamp + 2 hours);

        vm.expectRevert(SecurePriceOracle.StalePrice.selector);
        oracle.getPrice18();

        // Llega una nueva publicacion del oraculo.
        feed.setData(2800e8, block.timestamp);

        assertEq(oracle.getPrice18(), 2800 ether);
    }
}
