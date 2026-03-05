# Foundry Lottery

on-chain raffle contract using chainlink VRF v2.5 for randomness and chainlink automation for automatically picking winners at timed intervals

## build & test

```
forge build
forge test
```

## deploy (local)

```
anvil
make deploy
```

## deploy (sepolia)

```
make deploy ARGS="--network sepolia"
```
