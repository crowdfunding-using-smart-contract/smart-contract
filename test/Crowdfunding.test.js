const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crowdfunding", function () {
  let token, crowdfunding, owner, contributor, deployer;

  before(async function () {
    [deployer, owner, contributor] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy("OToken", "OTK", 1000000);
    await token.deployed();

    await token.transfer(contributor.address, 500);

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    crowdfunding = await Crowdfunding.deploy(token.address, owner.address);
    await crowdfunding.deployed();
  });

  describe("Project creation", function () {
    it("should allow users to create a project", async function () {
      await expect(
        crowdfunding.connect(owner).createProject(
          "Test Project", 
          "Description", 
          100, 
          Math.floor(Date.now() / 1000), 
          Math.floor(Date.now() / 1000) + 24 * 60 * 60 // 1 day from now
        )
      ).to.emit(crowdfunding, "ProjectCreated");
    });
  });

  describe("Contributing to a project", function () {
    beforeEach(async function () {
      await token.connect(contributor).approve(crowdfunding.address, 1000);
    });

    it("should allow contributions to active projects", async function () {
      await crowdfunding.connect(owner).createProject(
        "Active Project", 
        "An active project for funding", 
        300, 
        Math.floor(Date.now() / 1000), 
        Math.floor(Date.now() / 1000) + 24 * 60 * 60 // 1 day from now
      );

      // Check contributor token balance before contribution
      const initialBalance = await token.balanceOf(contributor.address);
      expect(initialBalance).to.be.above(100);

      // Attempt to contribute with an explicit gas limit
      await expect(
        crowdfunding.connect(contributor).contribute(1, 100, { gasLimit: 1000000 })
      ).to.emit(crowdfunding, "ContributionMade").withArgs(1, 100, contributor.address);

      const project = await crowdfunding.projects(1);
      expect(project.currentFunding).to.equal(100);

      const finalBalance = await token.balanceOf(contributor.address);
      expect(finalBalance).to.equal(initialBalance.sub(100));
    });
  });
});
