import { ethers } from "hardhat";

async function main() {
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy("OToken", "OTK", 1000000);
    await token.deployed();
    console.log(`Token deployed to: ${token.address}`);

    const [deployer] = await ethers.getSigners();

    const Escrow = await ethers.getContractFactory("Escrow");
    const escrow = await Escrow.deploy(token.address, deployer.address);
    await escrow.deployed();
    console.log(`Escrow deployed to: ${escrow.address}`);

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    const crowdfunding = await Crowdfunding.deploy(token.address, deployer.address, escrow.address);
    await crowdfunding.deployed();
    console.log(`Crowdfunding deployed to: ${crowdfunding.address}`);

    await escrow.setCrowdfundingContract(crowdfunding.address);
    console.log(`Escrow's Crowdfunding contract set to: ${crowdfunding.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
