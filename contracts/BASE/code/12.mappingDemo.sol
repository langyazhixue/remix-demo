// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.0 <0.9.0;
contract MappingTest {
    mapping(address => uint256) public balances;

    function update(uint256 _amount) public {
        balances[msg.sender] = _amount;
    }

    function getAmount() public view  returns(uint){
        return balances[msg.sender];
    }
}

contract Mapping {
    //从地址到uint的映射
    mapping(address => uint) public myMap;

    function get(address _addr) public view returns (uint) {
        //映射始终返回一个值。
				//如果从未设置该值，它将返回默认值。
        return myMap[_addr];
    }
    // 更新此地址的值 	
    function set(address _addr, uint _i) public {
        myMap[_addr] = _i;
    }

    function remove(address _addr) public {
				//将值重置为默认值
        delete myMap[_addr];
    }
}
//嵌套 mapping
contract NestedMapping {
    //嵌套映射（从地址映射到另一个映射）
    mapping(address => mapping(uint => bool)) public nested;

    function get(address _addr1, uint _i) public view returns (bool) {
        // 可以从嵌套映射中获取值
        return nested[_addr1][_i];
    }

    function set(
        address _addr1,
        uint _i,
        bool _boo
    ) public {
        nested[_addr1][_i] = _boo;
    }

    // 删除 mapping 的一个元素
    function remove(address _addr1, uint _i) public {
        delete nested[_addr1][_i];
    }
}
