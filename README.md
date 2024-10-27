# SigmaHop - Contracts

A seamless cross-chain USDC bridge powered by Wormhole & Circle's CCTP.

![Made-With-Solidity](https://img.shields.io/badge/MADE%20WITH-SOLIDITY-000000.svg?colorA=222222&style=for-the-badge&logoWidth=14&logo=solidity)
![Made-With-Wormhole](https://img.shields.io/badge/MADE%20WITH-wormhole-ffffff.svg?colorA=222222&style=for-the-badge&logoWidth=14)
![Made-With-Avalanche](https://img.shields.io/badge/Deployed%20on-Avalanche-ff0000.svg?colorA=222222&style=for-the-badge&logoWidth=14)
![Made-With-Optimism](https://img.shields.io/badge/Deployed%20on-Optimism-ff0000.svg?colorA=222222&style=for-the-badge&logoWidth=14)
![Made-With-Base](https://img.shields.io/badge/Deployed%20on-Base-0000ff.svg?colorA=222222&style=for-the-badge&logoWidth=14)
![Made-With-Circle](https://img.shields.io/badge/MADE%20WITH-CIRCLE-ffffff.svg?colorA=22222&style=for-the-badge&logoWidth=14)

> Sigma Hop enables users to transfer USDC across multiple testnets with a single signature:
>
> - Optimism Sepolia
> - Avalanche Fuji
> - Base Sepolia

---

This are the solidity smart contracts used for _[sigmahop.tech](https://sigmahop.tech/)_ which is built during the _[Sigma Sprint](https://sigma.wormhole.com/)_.

## Deployments

- **Optimism Sepolia / Base Sepolia / Avalanche Fuji**

  - Sigma Hop - [0x21f8A88B4Ff388539641e20e67E7078Ab3F61C07](https://testnet.routescan.io/address/0x21f8A88B4Ff388539641e20e67E7078Ab3F61C07)
  - SigmaUSDCVault - [0x9d45cd42575A9B2E359D6f32Af3Acb642A472756](https://testnet.routescan.io/address/0x9d45cd42575A9B2E359D6f32Af3Acb642A472756)
  - Sigma Forwarder - [0xAe8aAaF7cC380d236b8751Df76d31A46B1A15f92](https://testnet.routescan.io/address/0xAe8aAaF7cC380d236b8751Df76d31A46B1A15f92)
  - Sigma Proxy Factory - [0xb5A021AD9d77ca0bb8B1610ab5A3Ae7428B32eB2](https://testnet.routescan.io/address/0xb5A021AD9d77ca0bb8B1610ab5A3Ae7428B32eB2)
  - Open Batch Executor - [0x7a4A0e89e041a24550d644fa8387DbeaFE444A3E](https://testnet.routescan.io/address/0x7a4A0e89e041a24550d644fa8387DbeaFE444A3E)

#

> **Pre-requisites:**
>
> - Setup Node.js v18+ (recommended via [nvm](https://github.com/nvm-sh/nvm) with `nvm install 18`)
> - Install [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
> - Clone this repository

```bash
# Install dependencies
npm install

# fill environments
cp .env.example .env
```

## Development

```bash
# Compile all the contracts
npx hardhat compile

# Deploy on Avalanche Fuji, Check hardhat.config.js to check or add supported chains
npx hardhat run --network fuji scripts/deploy.js
```
