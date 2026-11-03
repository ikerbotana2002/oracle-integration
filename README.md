
# Oracle Integration

Educational Oracle Integration project using Solidity,
Foundry and Chainlink Data Feeds.

## Goal

Read ETH/USD prices from a Chainlink-compatible
AggregatorV3Interface and test the integration using
a local mock.

## Technologies

- Solidity 0.8.24
- Foundry
- Chainlink Data Feeds API

## Contracts

- `PriceConsumer.sol`: Reads the latest price,
  its decimals and update timestamp.
- `AggregatorV3Interface.sol`: Minimal interface
  compatible with Chainlink V3 Data Feeds.
- `MockPriceFeed.sol`: Local feed used in tests.

## Testing

```bash
forge build
forge test -vv
forge fmt --check
```

## Roadmap

- Day 45: Price Feed basics and first consumer
- Day 46: Price validation and decimal normalization
- Day 47: Security tests and stale-price protection
- Day 48: Integration and final documentation

## Disclaimer

Educational project. Not audited or production-ready.
```

### B. Configurar GitHub Actions

Así cada push compilará nuestro código y ejecutará las pruebas, igual que en los anteriores proyectos.

```bash
mkdir -p .github/workflows

touch .github/workflows/test.yml
```

Pega:

<CodeBlock language="yaml" editable>
name: CI

on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1

      - name: Check formatting
        run: forge fmt --check

      - name: Build
        run: forge build --sizes

      - name: Run tests
        run: forge test -vv
