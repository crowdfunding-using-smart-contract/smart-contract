import { ethers } from "hardhat";

async function main() {
    const Crowdfunding = await ethers.getContractFactory("MockCrowdfunding");
    const crowdfunding = await Crowdfunding.deploy();
  
    await crowdfunding.deployed();
  
    console.log("Crowdfunding deployed to:", crowdfunding.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  