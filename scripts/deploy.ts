import { ethers } from "hardhat";

async function main() {
  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy("OToken", "OTK", ethers.utils.parseEther("1000000"));
  await token.deployed();
  console.log(`Token deployed to: ${token.address}`);

  const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
  const crowdfunding = await Crowdfunding.deploy(token.address);
  await crowdfunding.deployed();
  console.log(`Crowdfunding deployed to: ${crowdfunding.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
