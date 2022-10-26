// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 <0.9.0;

import "./base64.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract Ex1 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping (uint256 => Item) items; // from itemId to item

    uint numberOfCreatedContracts = 0;
     struct Item {
        string title;
        string image64;
    }
    constructor() ERC721("Tasneem", "Ex1") { }

    function mintNFT(address owner, Item memory _item )
        public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        items[newItemId]=_item;
        _mint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI(newItemId));
        return newItemId;
    }

   

    function buyItem(string memory _title, string memory _image64) public payable {
        require(msg.value > .001 ether); // should be 0.001 ether
        require(numberOfCreatedContracts<1000);
        numberOfCreatedContracts += 1;
        Item memory _item = Item(_title,_image64);
        mintNFT(msg.sender, _item);
    }

    function modifyItem(string memory _title, string memory _image64, uint256 _tokenId) public{
        require(ownerOf(_tokenId) == msg.sender);
        items[_tokenId].image64 =_image64;
        items[_tokenId].title = _title;
    }
      function tokenURI(uint256 tokenId) override(ERC721URIStorage) public view returns (string memory) {
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"title": "', items[tokenId].title, '",',
                    '"image64": "', items[tokenId].image64, '",',
                    '}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }   
}