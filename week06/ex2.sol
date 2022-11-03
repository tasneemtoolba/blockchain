//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory name,string memory symbol) ERC721(name, symbol) {}

    function mintNFT(address recipient, string memory tokenURI)
        public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}

contract NFTGenerator is Ownable {
    mapping(address => MyNFT) public owners;
    mapping(address => bool) public hasCollection;
    MyNFT[] public nftCollections;
    function buyNFTCollection(string memory name, string memory symbol)public {
        // require(owners[msg.sender] == MyNFT(0x0));
        require(hasCollection[msg.sender] == false);

        MyNFT nft = new MyNFT(name, symbol);
        hasCollection[msg.sender] = true;
        
        owners[msg.sender] = nft;
        nft.transferOwnership(msg.sender);

        nftCollections.push(nft);
    }
    function retrieveNFTCollections ()public view returns(MyNFT[] memory) {
        return nftCollections;
    }
}

