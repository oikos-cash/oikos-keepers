require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-abi-exporter');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "ganache",
  networks: {
    hardhat: {
    },
    ganache: {
      url: "http://localhost:8545",
      gasPrice: 95358432601,
      accounts: [process.env.PRIVATE_KEY]
    },
    bsc: {
      url: process.env.PROVIDER_URL,
      gasPrice: 5000000000,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      bsc: process.env.ETHERSCAN_API_KEY,
    },
  },
  solidity: "0.8.13",
  abiExporter: {
    path: './abi',
    runOnCompile: false,
    clear: true,
    flat: false,
    only: [],
    spacing: 2,
    pretty: true,
  }
};
