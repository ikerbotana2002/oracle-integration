// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {PriceConsumer} from "../src/PriceConsumer.sol";
import {MockPriceFeed} from "./mocks/MockPriceFeed.sol";

contract PriceConsumerTest is Test {
    PriceConsumer consumer;
    MockPriceFeed mockFeed;

    int256 constant ETH_PRICE = 3000e8;

    function setUp() public {
        mockFeed = new MockPriceFeed(8, ETH_PRICE);

        consumer = new PriceConsumer(address(mockFeed));
    }

    function testGetLatestPrice() public view {
        assertEq(consumer.getLatestPrice(), 3000e8);
    }

    function testGetPriceDecimals() public view {
        assertEq(consumer.getPriceDecimals(), 8);
    }

    function testGetPriceDetails() public view {
        (int256 price, uint8 decimals_, uint256 updatedAt) = consumer.getPriceDetails();

        assertEq(price, 3000e8);
        assertEq(decimals_, 8);
        assertEq(updatedAt, block.timestamp);
    }

    function testPriceUpdates() public {
        vm.warp(block.timestamp + 1 hours);

        mockFeed.updateAnswer(3200e8);

        assertEq(consumer.getLatestPrice(), 3200e8);

        (int256 price,, uint256 updatedAt) = consumer.getPriceDetails();

        assertEq(price, 3200e8);
        assertEq(updatedAt, block.timestamp);
    }

    function testRevertWithInvalidFeed() public {
        vm.expectRevert(PriceConsumer.InvalidPriceFeed.selector);
        new PriceConsumer(address(0));

        vm.expectRevert(PriceConsumer.InvalidPriceFeed.selector);
        new PriceConsumer(address(0xBEEF));
    }
}
