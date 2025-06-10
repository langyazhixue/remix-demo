// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyToken is ERC20, ERC20Permit {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}
     //  this is a mint funciotn
    function mint(address to, uint256 value) external  {
        _mint(to, value);
    }
    //  this is a burn funciotn
    function burn(uint256 value) external  {
        _burn(msg.sender, value);
    }
}
