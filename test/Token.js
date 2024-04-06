const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", function () {
    let Token, token, owner, addr1, addr2;

    beforeEach(async function () {
        Token = await ethers.getContractFactory("Token");
        [owner, addr1, addr2, _] = await ethers.getSigners();

        token = await Token.deploy("ExampleToken", "EXT", ethers.utils.parseEther("1000000"));
    });

    describe("Deployment", function () {
        it("Should assign the total supply of tokens to the owner", async function () {
        const ownerBalance = await token.balanceOf(owner.address);
        expect(await token.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
        await token.transfer(addr1.address, ethers.utils.parseEther("50"));
        const addr1Balance = await token.balanceOf(addr1.address);
        expect(addr1Balance).to.equal(ethers.utils.parseEther("50"));
    
        await token.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("50"));
        const addr2Balance = await token.balanceOf(addr2.address);
        expect(addr2Balance).to.equal(ethers.utils.parseEther("50"));
        });
    
        it("Should fail if sender doesn’t have enough tokens", async function () {
        const initialOwnerBalance = await token.balanceOf(owner.address);
    
        await expect(
            token.connect(addr1).transfer(owner.address, ethers.utils.parseEther("1"))
        ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
    
        expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
        });
    
        it("Should update balances after transfers", async function () {
        const initialOwnerBalance = await token.balanceOf(owner.address);
    
        await token.transfer(addr1.address, ethers.utils.parseEther("100"));
    
        await token.transfer(addr2.address, ethers.utils.parseEther("50"));
    
        const finalOwnerBalance = await token.balanceOf(owner.address);
        expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(ethers.utils.parseEther("150")));
    
        const addr1Balance = await token.balanceOf(addr1.address);
        expect(addr1Balance).to.equal(ethers.utils.parseEther("100"));
    
        const addr2Balance = await token.balanceOf(addr2.address);
        expect(addr2Balance).to.equal(ethers.utils.parseEther("50"));
        });
    
        it("Should allow token approval and transfer from another account", async function () {
        await token.approve(addr1.address, ethers.utils.parseEther("100"));
        expect(await token.allowance(owner.address, addr1.address)).to.equal(ethers.utils.parseEther("100"));
    
        await token.connect(addr1).transferFrom(owner.address, addr2.address, ethers.utils.parseEther("100"));
        expect(await token.balanceOf(addr2.address)).to.equal(ethers.utils.parseEther("100"));
        expect(await token.allowance(owner.address, addr1.address)).to.equal(ethers.utils.parseEther("0"));
        });
    });
    
});
