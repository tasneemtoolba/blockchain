//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "prb-math/contracts/PRBMathSD59x18.sol";
import "base64.sol";

contract Ex2 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using PRBMathSD59x18 for int256;

    /// please deal with lat and lng as latD is lat in degress, then inputLat = latD * 1,000,000
    /// same for lng
    /// raduis is in km, please :(
    struct land{
        int lat; 
        int lng; 
        uint256 radius; 
        uint256 price;
    }

    mapping(uint256 => land) landData;
    mapping(uint256 => address) landToOwner;

    land[] lands;
    constructor() ERC721("Tasneem", "Ex2") {

    }

    function buyLand(int _lat, int _lng , uint _radius) public payable {
        /// First is to validate lat and lng
        /// Given that, the latitude must be a number between -90 and 90 and the longitude between -180 and 180.
        require(_lat>=-90000000 && _lat <= 90000000, "Invalid Latitude"); 
        require(_lng>=-180000000 && _lng <= 180000000, "Invalid Longitude"); 


        /// Second is to check whether the coordinates locate in some other land
        /// Given the equation of a circle is (x - x1)^2 + (y - y1)^2 = r^
        bool validLocation = true;
        for(uint256 i = 0;i < lands.length;i+=1){
            if( uint256(((lands[i].lat - _lat)**2) + ((lands[i].lng - _lng)**2)) == lands[i].radius * lands[i].radius){
                validLocation = false;
                break;
            }
        }
        require(validLocation, "The Given Coordinates are located inside another bought land, please try again");

        /// Third is to check for overlapping
        bool noOverlaping = true;
        for(uint256 i = 0;i < lands.length;i+=1){
            int x1 = lands[i].lat;
            int y1 = lands[i].lng;
            int x2 = _lat;
            int y2 = _lng;
            uint d = sqrt(uint256((x1 - x2) * (x1 - x2)
                         + (y1 - y2) * (y1 - y2)));
            uint r1 = lands[i].radius;
            if (d <= r1 - _radius || d <= _radius - r1 || d < r1 + _radius) {
               noOverlaping = false;
               break;
            }
            
        }
        require(noOverlaping, "The Given Coordinates & radius are overlapping with another bought land, please try again");


        /// the last thing is to check for price 
        land memory _land = land(_lat, _lng, _radius, calculatePrice(_radius));
        require(msg.value > _land.price * 1 ether); // should be _land.price
        uint256 _tokenId = mintNFT(msg.sender);
        landToOwner[_tokenId] = msg.sender;
        lands.push(_land);
    }


    function mintNFT(address owner)
        public onlyOwner
        returns (uint256)
    { 
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI(newItemId));
        return newItemId;
    }

    /// calculate land price
    function calculatePrice(uint _radius)private pure returns (uint ){
        uint price = sqrt(_radius * _radius * 3); /// considering pi as 3.... because I don't know how to deal with it otherwise.....
        return price;
    }
  function sqrt(uint y) internal pure returns (uint ) {
    uint z;
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
    return z;
}
    function tokenURI(uint256 tokenId) override(ERC721URIStorage) public view returns (string memory) {
    string memory json = Base64.encode(
        bytes(string(
            abi.encodePacked(
                '{"lat": "', landData[tokenId].lat, '",',
                '"lng": "', landData[tokenId].lng, '",',
                '"radius": "', landData[tokenId].radius, '",',
                '"price": "', landData[tokenId].price, '",',
               '}'
            )
        ))
    );
    return string(abi.encodePacked('data:application/json;base64,', json));
}  

}

