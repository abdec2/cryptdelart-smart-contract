// SPDX-License-Identifier: MIT
/** 
Author: Azim Baig & Noman ul Haq
Company: BRDigitech
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
import "@openzeppelin/contracts/utils/Strings.sol";

contract Cryptdelart is ERC1155, Ownable {
    uint256[] public swimSuit = [1,2,3,4,5,6,7,8];
    uint256[] public sleepWear = [9,10,11,12,13,14,15,16];
    uint256[] public sportsWear = [17,18,19,20,21,22,23,24];
    uint256[] public casualStyle = [25,26,27,28,29,30,31,32];
    uint256[] public elegantStyle = [33,34,35,36,37,38,39,40];
    uint256[] public exoticStyle = [41,42,43,44,45,46,47,48,49,50];
    uint256[] public maxSupply = [100,100,100,100,100,10];
    // uint256[] public costs = [600 ether, 1000 ether, 1500 ether, 3000 ether, 10000 ether, 100000 ether];
    // uint256[] public presaleCost = [480 ether, 800 ether, 1200 ether, 2400 ether, 8000 ether, 80000 ether];
    uint256[] public costs = [0.01 ether, 0.02 ether, 0.03 ether, 0.04 ether, 0.05 ether, 0.06 ether];
    uint256[] public presaleCost = [0.001 ether, 0.002 ether, 0.003 ether, 0.004 ether, 0.005 ether, 0.006 ether];
    uint256 public regularUserMintLimit = 1;
    uint256 public whitelistUserMintLimit = 2;
    uint256 public vipUserMintLimit = 6;    


    string public unRevealedUri = "https://gateway.pinata.cloud/ipfs/QmXup3miJgep1DbatMdG6nk5dxd3C8G5e9zVip726eteKA";
    string public baseURI = "https://gateway.pinata.cloud/ipfs/Qmc1v9Byw8UUSBg9DNvvgmY8srmeF6xya9LyTSmsHgUpk1/";
    string public baseExtension = ".json";
    string public name = "Cryptdelart NFT Collection";



    address[] public whiteListedUsers;
    address[] public vipUsers;

    bool public reveal = false;
    bool public presale = true;

    enum categories{ swimSuit,sleepWear,sportsWear,casualStyle,elegantStyle,exoticStyle }

    mapping(uint256 => uint256) public tokenAmountMinted;
    mapping(address => uint256) private noOfTokensMintedByUser;
    mapping(address => mapping(categories => uint256)) public noOfTokensMintedByUserPerCategory;

    constructor() ERC1155("") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 tokenId) override public view returns(string memory) {
        if(!reveal) {
            return unRevealedUri;
        }

        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), baseExtension));
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

    function mint(categories _category, uint256 tokenId)
        payable
        public
    {
        require(msg.value >= getCost(_category), "not enough ethers");
        require(tokenAmountMinted[tokenId] + 1 <= maxSupply[uint256(_category)], "Not enough supply");
        require(validateToken(_category, tokenId), "Token doesn't exist in this category");

        
        (bool _isWhiteList, ) = isWhitelistedUser(msg.sender);
        (bool _isVipUser, ) = isVipUser(msg.sender);
        if(_isWhiteList) {
            whitelistUserMint(_category, tokenId);
        } else if(_isVipUser) {
            vipUserMint(_category, tokenId);
        } else {
            if(!presale) {
                regularUserMint(_category, tokenId);
            } else {
                revert("You are not allowed to participate in presale");
            }

        } 
    }

    function validateToken(categories _category, uint256 tokenId) internal view returns(bool) {
        uint256[] memory tokenArray = getTokenArray(_category);
        bool result = false;
        for(uint256 i = 0; i < tokenArray.length; i++) {
            if(tokenId == tokenArray[i])
            {
                result = true;
            }
        }

        return result;
    }

    function getTokenArray(categories _category) internal view returns(uint256[] memory) {
        return (_category == categories.swimSuit) ? swimSuit : (_category == categories.sleepWear) ? sleepWear : (_category == categories.sportsWear) ? sportsWear : (_category == categories.casualStyle) ? casualStyle : (_category == categories.elegantStyle) ? elegantStyle : exoticStyle;
    }

    function regularUserMint(categories _category, uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < regularUserMintLimit, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][_category] = noOfTokensMintedByUserPerCategory[msg.sender][_category] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function whitelistUserMint(categories _category, uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < whitelistUserMintLimit, "Minting Limit Exceeds"); 
        require(noOfTokensMintedByUserPerCategory[msg.sender][_category] < 1, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][_category] = noOfTokensMintedByUserPerCategory[msg.sender][_category] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function vipUserMint(categories _category, uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < vipUserMintLimit, "Minting Limit Exceeds");
        require(noOfTokensMintedByUserPerCategory[msg.sender][_category] < 1, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][_category] = noOfTokensMintedByUserPerCategory[msg.sender][_category] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function getCost(categories _category) internal view returns(uint256) {
        if(presale) {
            return (_category == categories.swimSuit) ? presaleCost[0] : (_category == categories.sleepWear) ? presaleCost[1] : (_category == categories.sportsWear) ? presaleCost[2] : (_category == categories.casualStyle) ? presaleCost[3] : (_category == categories.elegantStyle) ? presaleCost[4] : (_category == categories.exoticStyle) ? presaleCost[5] : 0;
        }

        return (_category == categories.swimSuit) ? costs[0] : (_category == categories.sleepWear) ? costs[1] : (_category == categories.sportsWear) ? costs[2] : (_category == categories.casualStyle) ? costs[3] : (_category == categories.elegantStyle) ? costs[4] : (_category == categories.exoticStyle) ? costs[5] : 0;
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

    function setReveal(bool _reveal) external onlyOwner {
        reveal = _reveal;
    }

    function setPresale(bool _presale) external onlyOwner {
        presale = _presale;
    }

    function setBaseUri(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function setUnrevealUri(string memory _uri) external onlyOwner {
        unRevealedUri = _uri;
    }

    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "NFT: No ether left to withdraw");

        (bool success, ) = payable(owner()).call{ value: balance } ("");
        require(success, "NFT: Transfer failed.");
    }

    receive() external payable {}
    fallback() external payable {}
    
}