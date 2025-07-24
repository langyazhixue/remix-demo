// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

contract TokenBank is IERC1363Receiver {
    address public immutable token; // 预期的 ERC-1363 代币地址
    mapping(address => uint256) public balances;

    constructor(address tokenAddress) {
        token = tokenAddress;
    }
    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == token, "Invalid token"); // 关键：验证调用者
        balances[from] += value; // 业务逻辑（如更新余额）
        return this.onTransferReceived.selector; // 返回成功标识
    }
}