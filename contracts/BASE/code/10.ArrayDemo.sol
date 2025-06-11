// SPDX-License-Identifier: MIT;
pragma solidity >=0.7.0 <0.9.0;

contract ArrayDemo {
    // 创建定长数组
    uint256[5] public arr = [1, 2, 3, 4, 5];

    // 定长数组求和
    function getAll() public view returns (uint256) {
        uint256 num = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            num += arr[i];
        }
        return num;
    }

    function get() public view returns (uint256[5] memory) {
        return arr;
    }

    // 获取定长数组长度
    function getLenth() public view returns (uint256) {
        return arr.length;
    }

    // 修改长度失败
    function changeLenth() public {
        // arr.length = 7;
    }

    // 修改内部数据
    function change(uint256 _idx, uint256 _val) public {
        arr[_idx] = _val;
    }

    // push 修改
    // function change(uint256 _val) public {
    //     arr.push(_val);
    // }

    uint256[2][3] T = [[1, 2], [3, 4], [5, 6]];

    function T_len() public view returns (uint256) {
        return T.length; // uint256: 3
    }

    function getT() public view returns (uint256[2][3] memory) {
        return T;
    }

    function change() public {
        T[1][0] = 55;
    }

     function f() pure public {
        // g([1, 2, 3]); 
        g([uint(1),2,3]);
    }
    
    function g(uint[3] memory _data) pure public {
        // ...
    }
}
