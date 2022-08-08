// SPDX-License-Identifier: MIT
/** 


 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗██████╗ ███████╗██╗      █████╗ ██████╗ ████████╗
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██║     ██╔══██╗██╔══██╗╚══██╔══╝
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║  ██║█████╗  ██║     ███████║██████╔╝   ██║   
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║  ██║██╔══╝  ██║     ██╔══██║██╔══██╗   ██║   
╚██████╗██║  ██║   ██║   ██║        ██║   ██████╔╝███████╗███████╗██║  ██║██║  ██║   ██║   
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝   ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   

 Author: Azim Baig & Noman ul Haq
Company: BRDigitech
email: abdec2@hotmail.com
                                                                              
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Cryptdelart is ERC1155, Ownable {
    uint256[] public swimSuit = [1,2,3,4,5,6,7,8];
    uint256[] public maxSupply = [100,100,100,100,100,100,100,100];
    // uint256[] public costs = [600 ether, 1000 ether, 1500 ether, 3000 ether, 10000 ether, 100000 ether];
    // uint256[] public presaleCost = [480 ether, 800 ether, 1200 ether, 2400 ether, 8000 ether, 80000 ether];
    uint256 public cost = 0.2 ether;
    uint256 public presaleCost = 0.15 ether;
    uint256 public regularUserMintLimit = 1;
    uint256 public whitelistUserMintLimit = 8;
    uint256 public vipUserMintLimit = 8;    


    string public unRevealedUri = "https://gateway.pinata.cloud/ipfs/QmWBUWh2DCqwEDaEfcBgSEK6roS2Yn3iGdAVADiwNpuYHt/reveal.json";
    string public baseURI = "https://gateway.pinata.cloud/ipfs/QmeK5wzNuU4jp3ejY3Eg4FduJAzsitXA8EMBjdBVZ2Mt2t/";
    string public baseExtension = ".json";
    string public name = "Cryptdelart NFT Collection";



    address[] public whiteListedUsers;
    address[] public vipUsers;

    bool public reveal = false;
    bool public presale = true;

    mapping(uint256 => uint256) public tokenAmountMinted;
    mapping(address => uint256) private noOfTokensMintedByUser;
    mapping(address => mapping(uint256 => uint256)) public noOfTokensMintedByUserPerCategory;

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

    function mint(uint256 tokenId)
        payable
        public
    {
        require(msg.value >= getCost(), "not enough ethers");
        require(tokenAmountMinted[tokenId] + 1 <= maxSupply[tokenId - 1], "Not enough supply");
        require(validateToken(tokenId), "Token doesn't exist in this category");

        
        (bool _isWhiteList, ) = isWhitelistedUser(msg.sender);
        (bool _isVipUser, ) = isVipUser(msg.sender);
        if(_isWhiteList) {
            whitelistUserMint(tokenId);
        } else if(_isVipUser) {
            vipUserMint(tokenId);
        } else {
            if(!presale) {
                regularUserMint(tokenId);
            } else {
                revert("You are not allowed to participate in presale");
            }

        } 
    }

    function validateToken(uint256 tokenId) internal view returns(bool) {
        bool result = false;
        for(uint256 i = 0; i < swimSuit.length; i++) {
            if(tokenId == swimSuit[i])
            {
                result = true;
            }
        }

        return result;
    }

    function regularUserMint(uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < regularUserMintLimit, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][tokenId] = noOfTokensMintedByUserPerCategory[msg.sender][tokenId] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function whitelistUserMint(uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < whitelistUserMintLimit, "Minting Limit Exceeds"); 
        require(noOfTokensMintedByUserPerCategory[msg.sender][tokenId] < 1, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][tokenId] = noOfTokensMintedByUserPerCategory[msg.sender][tokenId] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function vipUserMint(uint256 tokenId) internal {
        require(noOfTokensMintedByUser[msg.sender] < vipUserMintLimit, "Minting Limit Exceeds");
        require(noOfTokensMintedByUserPerCategory[msg.sender][tokenId] < 1, "Minting Limit Exceeds");

        tokenAmountMinted[tokenId] = tokenAmountMinted[tokenId] + 1;
        noOfTokensMintedByUser[msg.sender] = noOfTokensMintedByUser[msg.sender] + 1;
        noOfTokensMintedByUserPerCategory[msg.sender][tokenId] = noOfTokensMintedByUserPerCategory[msg.sender][tokenId] + 1;
        _mint(msg.sender, tokenId, 1, ""); 
    }

    function getCost() internal view returns(uint256) {
        if(presale) {
            return presaleCost;
        }

        return cost;
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