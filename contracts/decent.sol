// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract decent is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address contractAddress;

  constructor(address marketplaceAddress) ERC721("Decent Music Tokens", "DEMU") {
  	contractAddress = marketplaceAddress;
  }

  function createToken(string memory tokenURI) public returns (uint) {
    //increment the _tokenIds
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    // mint the token
    _mint(msg.sender,newItemId);
    // set the token URI from ERC721URIStorage
    _setTokenURI(newItemId, tokenURI);
    // pass in contract contactAddress
    setApprovalForAll(contractAddress, true);
    // front end info
    return newItemId;
  }


}
