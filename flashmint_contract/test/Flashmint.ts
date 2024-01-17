import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { AaveMock, FlashminterMock, GhoMock, Wallet, WalletGHOFlashminter } from "../typechain-types";

describe("Flashmint", function () {

  async function deployTokenAndFacilitators() {
    
    const [owner, otherAccount] = await ethers.getSigners();

    const ghoMockFactory = await ethers.getContractFactory("GhoMock");
    const ghoMock: GhoMock = await ghoMockFactory.deploy();

    let ghoAddress = await ghoMock.getAddress();
    
    const flashminterMockFactory = await ethers.getContractFactory("FlashminterMock");
    const flashminterMock: FlashminterMock = await flashminterMockFactory.deploy(ghoAddress);

    let flashminterAddress = await flashminterMock.getAddress();

    const aaveMockFactory = await ethers.getContractFactory("AaveMock");
    const aaveMock: AaveMock = await aaveMockFactory.deploy(ghoAddress);

    let aaveAddress = await aaveMock.getAddress();

    const walletGhoFlashminterFactory = await ethers.getContractFactory("WalletGHOFlashminter");
    const walletGHOFlashminter: WalletGHOFlashminter = await walletGhoFlashminterFactory.deploy(
      flashminterAddress,
      ghoAddress
    );

    let walletGHOFlashminterAddress = await walletGHOFlashminter.getAddress();

    const walletFactory = await ethers.getContractFactory("Wallet");
    const wallet: Wallet = await walletFactory.deploy(
      ghoAddress,
      walletGHOFlashminterAddress,
      flashminterAddress,
      aaveAddress
    );

    return { ghoMock, flashminterMock, aaveMock, walletGHOFlashminter, wallet };
  }

  describe("Transfers should work", function () {
    it("should work", async function () {
      const { ghoMock, wallet, aaveMock } = await loadFixture(deployTokenAndFacilitators);
      let targetAccount = "0x583D6321A248212C53A3B38160C965B019075CA4";
      let targetAmount = 123;

      expect(await ghoMock.balanceOf(await wallet.getAddress())).to.equal(0);
      expect(await ghoMock.balanceOf(targetAccount)).to.equal(0);

      await wallet.transferGho(targetAccount, targetAmount);
      
      expect(await ghoMock.balanceOf(await wallet.getAddress())).to.equal(0);
      expect(await ghoMock.balanceOf(targetAccount)).to.equal(targetAmount);
      expect(await aaveMock.borrowed()).to.equal(targetAmount);

    });
  });

});
