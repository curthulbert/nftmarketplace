const hre = require("hardhat");

async function main() {
  const NFTMarket = await hre.ethers.getContractFactory("decentmarket");
  const nftMarket = await NFTMarket.deploy();
  await nftMarket.deployed();

   console.log("decentmarket deployed to:", nftMarket.address);
   
   const NFT = await ethers.getContractFactory("decent")
   const nft = await NFT.deploy(nftMarket.address)
   await nft.deployed()

   console.log("decent deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
