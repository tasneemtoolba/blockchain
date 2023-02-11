// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RewardToken is ERC20 {

    address internal owner;

    constructor() ERC20("Reward Token", "RT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

}
contract StakingNFTs is Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stake {
        ERC721 collection;
        bool isCollection;
        uint256[] tokenIds;
        address owner;
        uint256 beginTimestamp;
    }

    event CollectionStaked(address owner, uint256 tokenId, uint256 value);
    event ItemStaked(address owner, uint256 tokenId, uint256 value);
    event RewardDisrtibuted(address owner, uint256 amount);

    mapping (ERC721 => Stake) public stored;
    address rewardTokenFrom;
    mapping (uint256 => ERC721) public allowedCollections; // the whitelist
    ERC20 rewardToken;

    constructor(ERC20 rewardToken_, address rewardTokenFrom_) {
        rewardToken = rewardToken_;
        rewardTokenFrom = rewardTokenFrom_;
    }

    modifier collectionIDExists(uint256 collectionID) {
        require(address(allowedCollections[collectionID]) == address(0), "This collection ID doesn't exist");
        _;
    }

    // add whitelist input
    function addCollection(ERC721 collection) public onlyOwner {
        allowedCollections[_tokenIds.current()] = collection;
        _tokenIds.increment();
    }

    function stakeItem(uint256 collectionID, uint256 tokenId) public collectionIDExists(collectionID) {
        ERC721 collection = allowedCollections[collectionID];
        require(collection.ownerOf(tokenId) == msg.sender, "You are only allowed to stake your tokens");

        collection.transferFrom(msg.sender, address(this), tokenId);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        stored[collection] = Stake(collection, false, tokenIds, msg.sender, block.timestamp);

    }
    
    function stakeCollection(uint256 collectionID, uint256[] memory tokenIds) public collectionIDExists(collectionID) {
        require(tokenIds.length <= 10, "Your collection can contain at most 10 items");
        ERC721 collection = allowedCollections[collectionID];


        // the for-loop is not a bad practise in this case, casue the max. is 10 items
        for(uint j = 0; j < tokenIds.length; j++) {
            uint256 tokenId = tokenIds[j];
            require(collection.ownerOf(tokenId) == msg.sender, "You are only allowed to stake your tokens");
        }
        uint256[] memory _collectionTokenIds = new uint256[](tokenIds.length);
        
        for(uint j = 0; j < _collectionTokenIds.length; j++) {
            uint256 tokenId = _collectionTokenIds[j];
            _collectionTokenIds[j] = tokenId;

            collection.transferFrom(msg.sender, address(this), tokenId);
            emit CollectionStaked(msg.sender, tokenId, block.timestamp);
        }

        stored[collection] = Stake(collection, true, _collectionTokenIds, msg.sender, block.timestamp);

    }

    function unstakeItem(uint256 collectionID, uint256 tokenId) public collectionIDExists(collectionID){
        _claimItem(collectionID, msg.sender, tokenId);
    }

    function _claimItem(uint256 collectionID, address owner, uint256 tokenId) internal {
        ERC721 collection = allowedCollections[collectionID];

        Stake memory staked = stored[collection];
        require(owner == staked.owner, "You must be owner of this stake");

        uint256 beginTimestamp = staked.beginTimestamp;
        uint256 earned = 100 * ((block.timestamp - beginTimestamp) / 60);

        if (earned > 0) {
            rewardToken.transferFrom(rewardTokenFrom, owner, earned);
        }
        emit RewardDisrtibuted(owner, earned);
                    
        collection.transferFrom(address(this), staked.owner, tokenId);
        delete stored[collection];


    }

    function unstakeCollection(uint256 collectionID, uint256[] memory tokenIds) public collectionIDExists(collectionID){
        _claimCollection(collectionID, msg.sender, tokenIds);
    }

    function _claimCollection(uint256 collectionID, address owner, uint256[] memory tokenIds) internal {
            ERC721 collection = allowedCollections[collectionID];

            Stake memory staked = stored[collection];
            require(owner == staked.owner, "You must be owner of this stake");

            uint256 beginTimestamp = staked.beginTimestamp;
            uint256 earned = 10000 * ((block.timestamp - beginTimestamp) / 60);

            if (earned > 0) {
                rewardToken.transferFrom(rewardTokenFrom, owner, earned);
            }
            emit RewardDisrtibuted(owner, earned);
                        
            for(uint j = 0; j < tokenIds.length; j++) {
                uint256 tokenId = tokenIds[j];
                collection.transferFrom(address(this), staked.owner, tokenId);
            }
            delete stored[collection];
     
    }

    function earnedInfo(uint256 collectionID, uint256[] memory tokenIds) public collectionIDExists(collectionID) view returns(uint256)  {
        uint256 earned = 0;
        ERC721 collection = allowedCollections[collectionID];

        for(uint j = 0; j < tokenIds.length; j++) {
            Stake memory staked = stored[collection];
            require(msg.sender == staked.owner, "You must be owner of token");
        }

        for(uint j = 0; j < tokenIds.length; j++) {
            Stake memory staked = stored[collection];
            uint256 beginTimestamp = staked.beginTimestamp;
            
            if (staked.isCollection == true) {
                earned += 10000 * ((block.timestamp - beginTimestamp) / 60);
            } else {
                earned += 100 * ((block.timestamp - beginTimestamp) / 60);
            }
        }

        return earned;
    }

}