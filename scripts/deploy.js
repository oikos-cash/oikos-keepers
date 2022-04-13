const hre = require("hardhat");

async function main() {

  const ProtocolTasks = await hre.ethers.getContractFactory("ProtocolTasks");
  const ProtocolTasks = await ProtocolTasks.deploy();

  await ProtocolTasks.deployed();

  console.log("ProtocolTasks deployed to:", ProtocolTasks.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
