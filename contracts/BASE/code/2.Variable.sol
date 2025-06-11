// SPDX-License-Identifier: MIT; 
// 添加智能合约的许可协议
// pragma solidity ^0.8.7; 
pragma solidity >=0.7.0<0.9.0;

// 局部变量
// 在函数内部的临时变量 需改不会记录 也不会消耗gas费用
// 状态变量 
  // 保存在区块链上的变量 每次修改都会消耗gas费用
// 全局变量(内置变量)
contract Variable {
    // 状态变量
    uint public num;

    address public onwer;
    
    uint public value;

    constructor(uint _num) payable {
        num = _num;
        onwer = msg.sender;
        value = msg.value;
    }

    function setNum(uint _num) public {
        num = _num;
    } 
    // 局部变量
    function setLocalNum() public pure returns(uint) {
        uint age = 666;
        age ++;
        return age;
    }
    

    

}
// 134320