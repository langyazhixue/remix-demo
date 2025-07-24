// SPDX-License-Identifier: MIT
// by 0xAA
pragma solidity ^0.8.21;

import "./ERC1155.sol";

contract WoWInventory is ERC1155{
    // uint256 constant MAX_ID = 10000; 
    // 构造函数
    uint256 public constant GOLD = 1 ;
    uint256 public constant SILVER = 2 ;
    uint256 public constant COPPER = 3 ;
    uint256 public constant BLUNT_SWORD = 4 ;
    uint256 public constant DEATH_STING = 5 ;

    constructor() ERC1155("WoW", "WWI"){
      _mint(msg.sender, GOLD, 10**10,  '');
      _mint(msg.sender, SILVER, 10**15,  '');
      _mint(msg.sender, COPPER, 10**20,  '');
      _mint(msg.sender, BLUNT_SWORD, 10**10,  '');
      _mint(msg.sender, DEATH_STING, 1,  '');
    }

    //BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }
    
    // 铸造函数
    // function mint(address to, uint256 id, uint256 amount) external {
    //     // id 不能超过10,000
    //     require(id < MAX_ID, "id overflow");
    //     _mint(to, id, amount, "");
    // }

    // 批量铸造函数
    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external {
    //     // id 不能超过10,000
    //     for (uint256 i = 0; i < ids.length; i++) {
    //         // require(ids[i] < MAX_ID, "id overflow");
    //     }
    //     _mintBatch(to, ids, amounts, "");
    // }
}