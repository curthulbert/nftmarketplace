// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract decentmarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    // owner of the contract
    address payable owner;
    // determine the owner of the contract where the owner makes a comission - listing fee and transactions
    uint256 listingPrice = 0.025 ether; // we are not using ether but MATIC or SOL, but if it was ETH then this would be a huge fee

    constructor() {
      // setting the owner
      owner = payable(msg.sender);
    }

    struct MarketItem {
      uint itemId;
      address nftContract;
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated (
      uint indexed itemId,
      address indexed nftContract,
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    // create the market item or item for sale
    function createMarketItem(
      address nftContract,
      uint256 tokenId,
      uint256 price
    ) public payable nonReentrant {
      // price must be greater than ??
      require(price > 0, "Price must be at least 5 MATIC");
      // require a listing price
      require(msg.value == listingPrice, "Price must be equal to listing price");
      // increment out ids
      _itemIds.increment();
      // set the marketplace item
      uint256 itemId = _itemIds.current();

      // create our market item mapping
      idToMarketItem[itemId] = MarketItem(
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),
        // set this to no value as no one owns it yet
        payable(address(0)),
        price,
        false
      );
      // transfer the ownership of the nft to the contract itself to transfer to the next buyer
      IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

      emit MarketItemCreated(
        itemId,
        nftContract,
        tokenId,
        msg.sender,
        address(0),
        price,
        false
      );
    }

    function createMarketSale(
      address nftContract,
      uint256 itemId
    ) public payable nonReentrant {
      uint price = idToMarketItem[itemId].price;
      uint tokenId = idToMarketItem[itemId].tokenId;
      // make sure the person has sent in the correct amount of tokens
      require(msg.value == price, "Please submit the asking price in order to complete the transaction");
      // tranfer the value to the seller - sent money to seller
      idToMarketItem[itemId].seller.transfer(msg.value);
      // transfer the ownership of the toke to the buyer - sent asset to buyer
      IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
      // set the local owner of the item to the buyer
      idToMarketItem[itemId].owner = payable(msg.sender);
      // set the item to sold
      idToMarketItem[itemId].sold = true;
      // increment the items sold by 1
      _itemsSold.increment();
      // pay the owner of the contract
      payable(owner).transfer(listingPrice);
    }

    /* allows someone to resell a token they have purchased */
    function createMarketResale(address nftContract, uint256 tokenId, uint256 price) public payable {
      require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingPrice, "Price must be equal to listing price");
      idToMarketItem[tokenId].sold = false;
      idToMarketItem[tokenId].price = price;
      idToMarketItem[tokenId].seller = payable(msg.sender);
      idToMarketItem[tokenId].owner = payable(address(this));
      _itemsSold.decrement();

      IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    }

    // return all unsold items - view
    function findMarketItems() public view returns (MarketItem[] memory){
      // total number of items we have created
      uint itemCount = _itemIds.current();
      // total number of unsold items
      uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
      // incremental index
      uint currentIndex = 0;

      MarketItem[] memory items = new MarketItem[](unsoldItemCount);
      for (uint i = 0; i < itemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(0)) {
          uint currentId = idToMarketItem[i + 1].itemId;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    function findMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      // find all nfts that belog to the user
      for (uint i = 0; i < totalItemCount; i++){
        if (idToMarketItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == msg.sender) {
          uint currentId = idToMarketItem[i + 1].itemId;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    function findNFTsCreated() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      // find all nfts that belog to the buyer
      for (uint i = 0; i < totalItemCount; i++){
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = idToMarketItem[i + 1].itemId;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }
}
