
# Oracle Integration — Chainlink Price Feeds

An educational Solidity project demonstrating
how to consume Chainlink-compatible price feeds,
normalize prices, validate oracle responses and
integrate price data into DeFi collateral valuation.

Built with Solidity 0.8.24 and Foundry.

> Educational prototype. Not audited or production-ready.

## Overview

Smart contracts cannot directly request external
HTTP APIs during EVM execution.

Chainlink Data Feeds publish external market data
on-chain, allowing contracts to read the latest
available price through a deterministic interface.

This repository implements an increasingly robust
integration across four stages.

## Architecture

```text
External market data
        |
        v
Chainlink Data Feed
        |
        v
SecurePriceOracle
  - Positive price
  - Valid timestamp
  - Freshness check
  - Decimal normalization
        |
        v
CollateralValuator
  - ETH collateral value
  - Maximum LTV: 50%
  - Borrowing eligibility check
```

## Contracts

| Contract | Purpose |
|---|---|
| `PriceConsumer.sol` | Basic price feed consumer |
| `PriceOracle.sol` | Decimal normalization |
| `SecurePriceOracle.sol` | Validated and normalized price data |
| `CollateralValuator.sol` | USD collateral valuation and LTV calculations |
| `AggregatorV3Interface.sol` | Minimal Chainlink-compatible interface |

## Price normalization

Feed answers are integers scaled by their
respective decimal precision.

For example, 3000 USD with 8 decimals:

```text
answer = 300000000000
decimals = 8
```

The adapter converts supported prices to
18-decimal fixed-point representation.

```text
price18 = answer * 10^(18 - feedDecimals)
```

## Security

SecurePriceOracle validates:

- Positive oracle answers
- Nonzero timestamps
- Timestamps not in the future
- Maximum allowed data age
- Supported decimal precision
- Arithmetic overflow during normalization

The configured maximum age is application-specific.

A recent timestamp does not guarantee that a
market price is accurate or manipulation-resistant.

On L2 networks, additional checks such as sequencer
uptime may be necessary.

## Collateral valuation

CollateralValuator uses an ETH/USD oracle to
calculate the USD value of an ETH amount.

```text
collateralValueUsd18 =
    ethAmountWei * ethPrice18 / 1e18
```

It also provides:

- `getMaxBorrowUsd18()`
- `isBorrowAllowed()`

The example maximum LTV is 50%.

This contract does not custody collateral,
issue loans, track debt or implement liquidations.

## Tests

Foundry tests cover:

- Price feed readings
- Decimal normalization
- Price updates
- Invalid and negative answers
- Zero, future and stale timestamps
- Oracle failures
- Arithmetic overflow checks
- Collateral calculations
- LTV limits
- Changing collateral prices
- Fuzz testing

Run:

```bash
forge build
forge test -vv
forge fmt --check
```

Extended fuzz testing:

```bash
forge test \
  --match-test testFuzzCollateralValue \
  --fuzz-runs 1000
```

## Limitations

- The price feed address must be selected correctly.
- The contract assumes the selected feed provides
  the intended asset's USD price.
- Prices are not guaranteed to update every block.
- The freshness limit is a configuration decision.
- The adapter only supports feeds with up to
  18 decimals.
- Oracle accuracy and economic manipulation risks
  are not fully addressed.
- This is not a complete lending protocol.
- No independent security audit has been performed.

## Roadmap

- Day 45: Basic Chainlink consumer
- Day 46: Normalized price adapter
- Day 47: Secure oracle and adversarial tests
- Day 48: Collateral valuation integration

## Next Project

DeFi Lending Protocol — collateral deposits,
borrowing, debt accounting, repayments,
health factors and liquidations.

## Resumen en español

Integración educativa de oráculos compatibles con
Chainlink para consultar precios, normalizarlos,
validarlos y utilizarlos en cálculos financieros DeFi.

Incluye un contrato de valoración de garantías
en ETH y reglas de préstamo basadas en LTV.

No gestiona fondos reales ni implementa préstamos.
