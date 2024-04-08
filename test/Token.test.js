const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function () {
    let Token, token, owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        Token = await ethers.getContractFactory("Token");
        token = await Token.deploy("ExampleToken", "EXT", 1000000);
        await token.deployed();
    });

    describe("Deployment", function () {
        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await token.balanceOf(owner.address);
            const totalSupply = await token.totalSupply();
            expect(ownerBalance).to.equal(totalSupply);
        });

        it("Has a name", async function () {
            expect(await token.name()).to.equal("ExampleToken");
        });

        it("Has a symbol", async function () {
            expect(await token.symbol()).to.equal("EXT");
        });

        it("Assigns initial balance correctly", async function () {
            const expectedBalance = ethers.utils.parseEther("1000000");
            const ownerBalance = await token.balanceOf(owner.address);
            expect(ownerBalance).to.equal(expectedBalance);
        });
    });
});