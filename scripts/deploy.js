const hre = require("hardhat");

async function main() {

  const ProtocolTasks = await hre.ethers.getContractFactory("ProtocolTasks");
  const protocolTasks = await ProtocolTasks.deploy();

  await protocolTasks.deployed();

  console.log("ProtocolTasks deployed to:", protocolTasks.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


