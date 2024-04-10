import { ethers } from "hardhat";

async function main() {
    // const Token = await ethers.getContractFactory("Token");
    // const token = await Token.deploy("OToken", "OTK", 1000000);
    // await token.deployed();
    // console.log(`Token deployed to: ${token.address}`);
    // 0x3b539Bf35E53C452052Ae1CA3cb9893b928C047E

    const [deployer] = await ethers.getSigners();

    // const Escrow = await ethers.getContractFactory("Escrow");
    // const escrow = await Escrow.deploy('0x3b539Bf35E53C452052Ae1CA3cb9893b928C047E', deployer.address);
    // await escrow.deployed();
    // console.log(`Escrow deployed to: ${escrow.address}`);
    // 0x98Ad9eaa72a74DF44E1CAd9CfB4B6584fb4882d1

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    const crowdfunding = await Crowdfunding.deploy('0x3b539Bf35E53C452052Ae1CA3cb9893b928C047E', deployer.address, '0x98Ad9eaa72a74DF44E1CAd9CfB4B6584fb4882d1');
    await crowdfunding.deployed();
    console.log(`Crowdfunding deployed to: ${crowdfunding.address}`);
    // 0x9A987033226Cae1036A461868deD1C615928bf13

    // await escrow.setCrowdfundingContract(crowdfunding.address);
    const Escrow = await ethers.getContractFactory("Escrow");
    const escrow = Escrow.attach('0x98Ad9eaa72a74DF44E1CAd9CfB4B6584fb4882d1');

    const tx = await escrow.setCrowdfundingContract(crowdfunding.address);
    await tx.wait();

    console.log(`Escrow's Crowdfunding contract set to: ${crowdfunding.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
