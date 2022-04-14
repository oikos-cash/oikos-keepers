# oikos-keepers 
### This repository contains the Oikos Chainlink keepers smart contract code.

## Tasks
* notifyRewardAmounts (Notify weekly reward amounts to reward contracts)
* mintAndCloseFeePeriod (Mint weekly inflationary supply and close fee pool period)


## Requirements
- Node v14 or higher
- Hardhat 

## 1. Setup 

To setup and install dependencies please run:

```bash
# setup (install all dependencies)
npm install
```

## 2. Build
Will compile bytecode and ABIs for all .sol files found in node_modules and the contracts folder. It will output them in the artifacts folder.

```bash
# build (compile all .sol sources)
npm run build
```


## 3. Deploy
Will attempt to deploy all of the contracts.

:warning: **This step requires the `build` step having been run to compile the sources into ABIs and bytecode.**

```bash
# deploy (deploy compiled .sol sources)
npm run deploy-ganache
```

To deploy the code on multiple networks the hardhat.config.js file needs to be adjusted, see instructions [here](https://hardhat.org/config/).

