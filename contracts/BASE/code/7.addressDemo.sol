// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransferExample {
    // 使用 transfer()
    function sendViaTransfer(address payable _to) public payable {
        _to.transfer(msg.value);
    }
    // 使用 call() - 推荐方式
    function sendViaCall(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    
    // 接收以太币的函数
    receive() external payable {}
}