// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// 利用@openzeppelin 规范实现 
contract MyToken is ERC721 {
    constructor() ERC721("MyToken", "MTK") {}

    function _baseURI() internal pure override returns (string memory) {
        return "http://test/com";
    }
    function mint (address to, uint256 tokenId) public  {
        _safeMint(to, tokenId);
    }
    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
    // function setApprovalForAll(address operator, bool approved) public override {
    //     super.setApprovalForAll(operator, approved);
    // }
}


//  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 给  1 2 3 4 5 NFT
//   0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 给   6 7 8 NFT 授权给  0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB 转所有币


// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 给 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 授权 1  

//  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 转 1  到 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

//  0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB 转账 2

//  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  safeTransferFrom 4 gei 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB


