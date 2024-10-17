require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
        details: {
          yulDetails: {
            optimizerSteps: "u",
          },
        },
      },
      evmVersion: "paris",
      viaIR: true,
    },
  },
  networks: {
    opSepolia: {
      url: `https://sepolia.optimism.io/`,
      accounts: [PRIVATE_KEY],
    },
    baseSepolia: {
      url: `https://sepolia.base.org`,
      accounts: [PRIVATE_KEY],
    },
    fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      opSepolia: "89K6NC1QZIUZSA6A6S5SY1N3DVIBCJCD3A",
      baseSepolia: "BZP99H9U5SEDZTTP3BIBUYE5X2TMM9PX5Q",
      fuji: "your API key",
    },
    customChains: [
      {
        network: "opSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
          browserURL: "https://sepolia-optimism.etherscan.io/",
        },
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org/",
        },
      },

      {
        network: "fuji",
        chainId: 43113,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
          browserURL: "https://c-chain.snowtrace.io",
        },
      },
    ],
  },
};
