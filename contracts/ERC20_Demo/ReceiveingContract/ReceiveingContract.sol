
// 智能合约的许可协议
// SPDX-License-Identifier:MIT

// 版本声明
// pragma solidity >=0.8.4 <0.9.0;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
pragma solidity ^0.8.28;

contract ReceivingContract {
    // 存储哪个用户给了我这个多少代币
    mapping(address =>uint256) private _deposits;
    IERC20 public  erc20;
    constructor(IERC20 token) {
        erc20 = token;
    }
	function deposit(uint256 amount) external returns(bool){
		// 如果未经批准或用户余额不足，将会回滚
		erc20.transferFrom(msg.sender, address(this), amount);
		_deposits[msg.sender] += amount;
        return true;
	}
    function deposits(address account ) external view returns (uint256){
        return _deposits[account];
    }
    function receive external  payable (){}
}
