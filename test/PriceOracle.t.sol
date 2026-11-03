// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PriceOracle} from "../src/PriceOracle.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

contract PriceOracleTest is Test {
    MockPriceFeed feed;
    PriceOracle oracle;

    function setUp() public {
        feed = new MockPriceFeed(8, 3000e8);
        oracle = new PriceOracle(address(feed));
    }

    function testNormalizesEightDecimals() public view {
        assertEq(oracle.feedDecimals(), 8);
        assertEq(oracle.getPrice18(), 3000 ether);
    }

    function testNormalizesSixDecimals() public {
        MockPriceFeed sixDecimalFeed = new MockPriceFeed(6, 2500e6);

        PriceOracle sixDecimalOracle = new PriceOracle(address(sixDecimalFeed));

        assertEq(sixDecimalOracle.getPrice18(), 2500 ether);
    }

    function testKeepsEighteenDecimals() public {
        MockPriceFeed eighteenDecimalFeed = new MockPriceFeed(18, 3200e18);

        PriceOracle eighteenDecimalOracle = new PriceOracle(address(eighteenDecimalFeed));

        assertEq(eighteenDecimalOracle.getPrice18(), 3200 ether);
    }

    function testReadsUpdatedPrice() public {
        feed.updateAnswer(3500e8);

        assertEq(oracle.getPrice18(), 3500 ether);
    }

    function testRevertsWhenPriceIsZero() public {
        feed.updateAnswer(0);

        vm.expectRevert(PriceOracle.InvalidPrice.selector);

        oracle.getPrice18();
    }

    function testRevertsWhenPriceIsNegative() public {
        feed.updateAnswer(-100e8);

        vm.expectRevert(PriceOracle.InvalidPrice.selector);

        oracle.getPrice18();
    }

    function testRejectsUnsupportedDecimals() public {
        MockPriceFeed invalidFeed = new MockPriceFeed(19, 3000e18);

        vm.expectRevert(PriceOracle.UnsupportedDecimals.selector);

        new PriceOracle(address(invalidFeed));
    }

    function testRejectsInvalidFeedAddress() public {
        vm.expectRevert(PriceOracle.InvalidPriceFeed.selector);

        new PriceOracle(address(0));
    }
}
