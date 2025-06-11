// SPDX-License-Identifier: MIT; 
// 添加智能合约的许可协议
// pragma solidity ^0.8.7; 
pragma solidity >=0.7.0<0.9.0;

contract HelloWord {
    string name; 
    uint public age;
    constructor() {
        // 构造函数部署初始化的时候执行
        name = "hmm";
        age = 16;
    }

    function getName() public view returns(string memory) {
        return name;
    }
}