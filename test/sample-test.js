const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarket", function () {
  it("Should create and execute market sales", async function () {
    const Market = await ethers.getContractFactory("decentmarket")
    const market = await Market.deploy()
    await market.deployed()

    const marketAddress = market.address

    const NFT = await ethers.getContractFactory("decent")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let lisitngPrice = await market.getListingPrice()
    lisitngPrice = lisitngPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('10', 'ether')

    await nft.createToken("https://mytokenlocation.com")
    await nft.createToken("https://mytokenlocation2.com")

    await market.createMarketItem(nftContractAddress, 1 , auctionPrice, { value: lisitngPrice })
    await market.createMarketItem(nftContractAddress, 2 , auctionPrice, { value: lisitngPrice })

    const [_, buyerAddress] = await ethers.getSigners()

    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1 , { value: auctionPrice })

    let items = await market.findMarketItems()

    items = await Promise.all(items.map(async i => {
      const tokenURI = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenURI
      }
      return item
    }))

    console.log('items: ', items)

  });
});
