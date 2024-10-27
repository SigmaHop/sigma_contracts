// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const contract = await hre.ethers.deployContract(
    "SigmaProxyFactory",
    [
      "0x9d45cd42575A9B2E359D6f32Af3Acb642A472756",
      "0x5425890298aed601595a70ab815c96711a31bc65",
      "0xAe8aAaF7cC380d236b8751Df76d31A46B1A15f92",
      "0xDb1d125C9f7faE45d7CeE470d048670a85270f4D",
    ],
    {
      gasLimit: 2000000,
    }
  );

  console.log("Contract address:", await contract.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
