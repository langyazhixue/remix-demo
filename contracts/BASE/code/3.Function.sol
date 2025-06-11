// SPDX-License-Identifier: MIT; 
pragma solidity >=0.7.0<0.9.0;

contract Function {
    uint age;

    constructor() {
        age = 18;
    }
    // 对外可见的修改状态变量的方法
    function setAge() public {
        age += 1;
    }
    // 对外可见的使用状态变量的方法 view
    function getAge() public view returns(uint) {
        return age;
    }
    // 对外可见的不适用状态变量的方法
    function getAge2() public pure returns(uint ,string memory){
        return (66,"abc");
    }
}