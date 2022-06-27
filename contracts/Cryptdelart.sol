// SPDX-License-Identifier: MIT
/** 
Author: Azim Baig
email: abdec2@hotmail.com

 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗██████╗ ███████╗██╗      █████╗ ██████╗ ████████╗
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██║     ██╔══██╗██╔══██╗╚══██╔══╝
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║  ██║█████╗  ██║     ███████║██████╔╝   ██║   
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║  ██║██╔══╝  ██║     ██╔══██║██╔══██╗   ██║   
╚██████╗██║  ██║   ██║   ██║        ██║   ██████╔╝███████╗███████╗██║  ██║██║  ██║   ██║   
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝   ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
                                                                              
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cryptdelart is ERC1155, Ownable {
    uint256[] public swimSuit = [1,2,3,4,5,6,7,8];
    uint256[] public sleepWear = [9,10,11,12,13,14,15,16];
    uint256[] public sportsWear = [17,18,19,20,21,22,23,24];
    uint256[] public casualStyle = [25,26,27,28,29,30,31,32];
    uint256[] public elegantStyle = [33,34,35,36,37,38,39,40];
    uint256[] public exoticStyle = [41,42,43,44,45,46,47,48,49,50];
    uint256[] public swimSuitMaxSupply = [100,100,100,100,100,100,100,100];
    uint256[] public sleepWearMaxSupply = [100,100,100,100,100,100,100,100];
    uint256[] public sportsWearMaxSupply = [100,100,100,100,100,100,100,100]; 
    uint256[] public casualStyleMaxSupply = [100,100,100,100,100,100,100,100];
    uint256[] public elegantStyleMaxSupply = [100,100,100,100,100,100,100,100];
    uint256[] public exoticStyleMaxSupply = [10,10,10,10,10,10,10,10,10,10];
    uint256[] public costs = [600, 1000, 1500, 3000, 10000, 100000];
    uint256[] public presaleCost = [480, 800, 1200, 2400, 8000, 80000];

    string public revealedUri = "";

    address[] public whiteListedUsers;
    address[] public vipUsers;

    bool public unrevealed = false;
    bool public presale = true;

    enum categories{ swimSuit,sleepWear,sportsWear,casualStyle,elegantStyle,exoticStyle }

    mapping(categories => uint256) private lastMintedToken;

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(categories _category)
        payable
        public
    {
        require(msg.value >= getCost(_category), "not enough ethers");

        uint256 id = getTokenId(_category);
        
        _mint(msg.sender, id, 1, ""); 
    }

    function getTokenId(categories _category) internal view returns(uint256) {
        uint256 lastMintId = lastMintedToken[_category];
        lastMintId = lastMintId + 1;
        uint256[] memory tokenArray = getTokenArray(_category);
        uint256 tokenToMint = tokenArray[0];
        if(lastMintId < tokenArray[tokenArray.length - 1]) {
            return lastMintId;
        }

        return tokenToMint;
    }

    function getCost(categories _category) internal view returns(uint256) {
        if(presale) {
            return (_category == categories.swimSuit) ? presaleCost[0] : (_category == categories.sleepWear) ? presaleCost[1] : (_category == categories.sportsWear) ? presaleCost[2] : (_category == categories.casualStyle) ? presaleCost[3] : (_category == categories.elegantStyle) ? presaleCost[4] : (_category == categories.exoticStyle) ? presaleCost[5] : 0;
        }

        return (_category == categories.swimSuit) ? costs[0] : (_category == categories.sleepWear) ? costs[1] : (_category == categories.sportsWear) ? costs[2] : (_category == categories.casualStyle) ? costs[3] : (_category == categories.elegantStyle) ? costs[4] : (_category == categories.exoticStyle) ? costs[5] : 0;
    }

    function getTokenArray(categories _category) internal view returns(uint256[] memory) {
        return (_category == categories.swimSuit) ? swimSuit : (_category == categories.sleepWear) ? sleepWear : (_category == categories.sportsWear) ? sportsWear : (_category == categories.casualStyle) ? casualStyle : (_category == categories.elegantStyle) ? elegantStyle : exoticStyle;
    }

    function isWhitelistedUser(address _address) public view returns(bool, uint256) {
        for(uint256 i=0; i < whiteListedUsers.length; i++) {
            if(_address == whiteListedUsers[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function isVipUser(address _address) public view returns(bool, uint256) {
        for(uint256 j = 0; j < vipUsers.length; j++) {
            if(_address == vipUsers[j]) {
                return (true, j);
            }
        }
        return (false, 0);
    }

    function addWhitelistedUser(address _address) public onlyOwner {
        whiteListedUsers.push(_address);
    }

    function addVipUser(address _address) public onlyOwner {
        vipUsers.push(_address);
    }

    function removeWhitelistUser(address _address) public onlyOwner {
        (bool _isWhitelistedUser, uint256 s) = isWhitelistedUser(_address);
        if(_isWhitelistedUser){
            whiteListedUsers[s] = whiteListedUsers[whiteListedUsers.length - 1];
            whiteListedUsers.pop();
        } 
    }

    function removeVipUser(address _address) public onlyOwner {
        (bool _isVipUser, uint256 s) = isVipUser(_address);
        if(_isVipUser){
            vipUsers[s] = vipUsers[vipUsers.length - 1];
            vipUsers.pop();
        } 
    }

    
}