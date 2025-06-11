// SPDX-License-Identifier: MIT; 
pragma solidity >=0.7.0<0.9.0;

contract AddressDemo{
    address public test;
    address public owner;
    address public contractAddress;
    constructor() {
        owner = msg.sender;
        contractAddress = address(this);
    }
    function getBalance(address _address) public view returns(uint) {
        return _address.balance;
    }
}
