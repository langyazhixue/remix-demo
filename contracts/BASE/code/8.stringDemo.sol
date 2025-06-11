// SPDX-License-Identifier: MIT; 
pragma solidity >=0.7.0<0.9.0;

contract StringDemo {
    string public name = unicode'韩梅梅';
    string public a = unicode'李雷雷';
    function getLength() public view returns(uint) {
        // 不能直接使用length方法
        // return name.length;
        // return bytes(name).length;
    }
    // 不能直接拼接
    // function cancat() public view returns(string memory) {
    //     return name + a;
    // }
    function concat() public view returns(bytes memory) {
        // return  string.concat(name,a);
        bytes memory _a = bytes(name); 
        bytes memory _b = bytes(a);
        return bytes.concat(_a,_b);
    }

     function concat1() public view returns(string memory) {
        // return  string.concat(name,a);
        bytes memory _a = bytes(name); 
        bytes memory _b = bytes(a);
        return string(bytes.concat(_a,_b));
    }

     function concat2() public view returns(bytes memory) {
        return abi.encodePacked(name, a);
    }
     function concat3() public view returns(string memory) {
        return string(abi.encodePacked(name, a));
    }

    function isLike(string memory _a, string memory _b) public pure returns(bool) {
        // return _a == _b;
         return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
     
}