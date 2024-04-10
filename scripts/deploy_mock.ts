// Import ethers from Hardhat package
const { ethers } = require("hardhat");

async function main() {
  // Deploy Token contract
  // const Token = await ethers.getContractFactory("Token");
  // const token = await Token.deploy("OToken", "OTK", ethers.utils.parseEther("1000000"));
  // await token.deployed();
  // console.log("Token deployed to:", token.address);

  // Deploy MockCrowdfunding contract
  const MockCrowdfunding = await ethers.getContractFactory("MockCrowdfunding");
  const crowdfunding = await MockCrowdfunding.deploy('0x3b539Bf35E53C452052Ae1CA3cb9893b928C047E');
  await crowdfunding.deployed();
  console.log("MockCrowdfunding deployed to:", crowdfunding.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
