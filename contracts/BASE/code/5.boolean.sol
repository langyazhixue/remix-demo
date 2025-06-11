// SPDX-License-Identifier: MIT; 
pragma solidity >=0.7.0<0.9.0;

contract Boolean {
    bool public isshow;
    bool public A; // false
	bool public B = true;	//true
  	// require(A==B,"A not equal B");

    function test() public view returns(bool) {
        // return A == B;
        return A !=B; 
    }
}