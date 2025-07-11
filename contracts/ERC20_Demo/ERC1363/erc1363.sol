// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363.sol";
// import {IERC1363Receiver} from  "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";


contract MyToken is ERC20, IERC1363 {
    using Address for address;

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }

    // 实现 transferAndCall
    function transferAndCall(address to, uint256 value, bytes calldata data) external override returns (bool) {
        transfer(to, value); // 执行 ERC-20 转账
        require(_checkAndCallTransfer(msg.sender, to, value, data), "ERC1363: _checkAndCallTransfer failed");
        return true;
    }

    // 内部函数：触发接收合约的回调
    function _checkAndCallTransfer(address from, address to, uint256 value, bytes memory data) internal returns (bool) {
        if (to.isContract()) {
            // 调用接收合约的 onTransferReceived
            try IERC1363Receiver(to).onTransferReceived(msg.sender, from, value, data) returns (bytes4 retval) {
                return retval == IERC1363Receiver.onTransferReceived.selector;
            } catch {
                revert("ERC1363: onTransferReceived failed");
            }
        }
        return true;
    }

    // 省略其他必要函数（transferFromAndCall, approveAndCall 等）
}