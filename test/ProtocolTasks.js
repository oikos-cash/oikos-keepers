const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { yellow, green, red } = require("chalk");

const ERC20_ABI = require("../abi/contracts/interfaces/IERC20.sol/IERC20.json");
const PROTOCOLTASKS_ABI = require("../abi/contracts/ProtocolTasks.sol/ProtocolTasks.json");
const CAKEPOOL_ABI = require("../abi/contracts/interfaces/ICakePool.sol/ICakePool.json");

const {
	toBN,
	toWei,
	fromWei,
	hexToAscii,
	rightPad,
	asciiToHex
} = require('web3-utils');

const toBytes32 = key => rightPad(asciiToHex(key), 64);
const fromBytes32 = key => hexToAscii(key);

describe(yellow("Protocol automation"), accounts => {

        it("should test execution", async function() {

            const [owner] = await ethers.getSigners();

            const ProtocolTasks = await hre.ethers.getContractAt(
                PROTOCOLTASKS_ABI, 
                "0xb26f758aFB170547D2F213d79A80B095Ce1998A7", 
                owner
            );  
            
            try {
                await ProtocolTasks._performUpkeep([]);
            } catch (err) { 
                assert(err.message == "VM Exception while processing transaction: revert Too early to close fee period");
            }
        });



        it("should not fail to notify rewards", async function() {

            const [owner] = await ethers.getSigners();

            //Hardcoded address was set as reward distribution address in the rewards contract
            const ProtocolTasks = await hre.ethers.getContractAt(
                PROTOCOLTASKS_ABI, 
                "0xb26f758aFB170547D2F213d79A80B095Ce1998A7", 
                owner
            );  
            
            try {
                 ProtocolTasks._notifyRewardAmounts([]);
            } catch (err) { 
                assert(err.message != "VM Exception while processing transaction: revert Caller is not reward distribution");
            }
        });

        it("should fail to notify rewards", async function() {

            const [owner] = await ethers.getSigners();

            const ProtocolTasks = await hre.ethers.getContractAt(
                PROTOCOLTASKS_ABI, 
                "0x9Cc5873D2819626520F977c8cd6beaedF92D48Ab", 
                owner
            );  
            
            await expect(ProtocolTasks._notifyRewardAmounts([]))
            .to.be.revertedWith('VM Exception while processing transaction: revert Caller is not reward distribution');

        });




        
        




});