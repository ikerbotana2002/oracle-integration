
## Day 46 - Price Oracle Adapter

Added `PriceOracle.sol`, an adapter for
Chainlink-compatible price feeds.

Features:
- Normalization of prices to 18 decimals
- Support for feeds with up to 18 decimals
- Rejection of zero and negative answers
- Rejection of unsupported feed precision
- Immutable price feed reference

Tests cover decimal normalization, price changes,
invalid answers and invalid feed configurations.

Security note:
The adapter does not yet verify price freshness.
Stale-price protection will be added next.
