// SPDX-License-Identifier: MIT; 
pragma solidity >=0.7.0<0.9.0;

// 修改值的方法只有合约的创建者可以调用

contract ErrorDemo {
    address owner;
    string public tag;
    uint public  age ;

    event Test(uint);
    constructor() {
        owner = msg.sender;
        tag = "abc";
        age = 1;
    }

    function add() public {
        age ++;
        emit Test(age);
    }
    function changeTag() public {
        // if(msg.sender == owner) {
        //     tag = "abcd";
        // }
        require(msg.sender== owner,"this must be owner call");
        tag = "abcd";
    }
}