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


    enum categories{ swimSuit,sleepWear,sportsWear,casualStyle,elegantStyle,exoticStyle }

    mapping(categories => uint256) private lastMintedToken;

    bool public unrevealed = false;
    bool public presale = true;

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(categories _category, uint256 mintAmount)
        payable
        public
    {
        require(msg.value >= getCost(_category), "not enough ethers");

        uint256 id = getTokenId(_category);
        
        _mint(msg.sender, id, mintAmount, ""); 
    }

    function getTokenId(categories _category) internal view returns(uint256) {

    }

    function getCost(categories _category) internal view returns(uint256) {

    }

    
}