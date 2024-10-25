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
    "SigmaHop",
    [
      "0xA3cF45939bD6260bcFe3D66bc73d60f19e49a8BB",
      "0x7bbcE28e64B3F8b84d876Ab298393c38ad7aac4C",
      "0xa9fb1b3009dcb79e2fe346c16a604b8fa8ae0a79",
      "0xeb08f243e5d3fcff26a9e38ae5520a669f4019d0",
      "0x5425890298aed601595a70ab815c96711a31bc65",
    ],
    {
      gasLimit: 1000000,
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
