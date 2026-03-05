# Foundry DeFi Stablecoin

overcollateralized stablecoin system backed by WETH and WBTC. uses chainlink price feeds for oracle data. the DSC token is pegged to USD and the system is always overcollateralized (200% threshold)

## build & test

```
forge build
forge test
```

## deploy

```
anvil
make deploy
```

## deploy (sepolia)

```
make deploy ARGS="--network sepolia"
```
