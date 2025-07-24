// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC20.sol";

contract Vault01 {
    IERC20 public immutable token;
    // 整个凭证总数
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(IERC20 _token) {
        token = _token;
    }

    function _mint(address _to, uint256 _shares) private {
        totalSupply += _shares; // totalSupply 增加
        balanceOf[_to] += _shares; // 这个账户的_shares 增加
    }

    function _burn(address _from, uint256 _shares) private {

        totalSupply -= _shares; // totalSupply 减少
        balanceOf[_from] -= _shares; // 这个账户的_shares 余额减少 ？？？？
    }
    // 充值
    function deposit(uint256 _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = share total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            // _amount = 1
            // totalSupply 1000
            // token.balanceOf(address(this)) 10000
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }
        token.transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, shares);
    }

    // 提取 withdraw？？？
    function withdraw(uint256 _shares) external {
        // token的比例 跟 share 的比例一定要一致～～～～抓重点
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        uint amount = (_shares * totalSupply) / totalSupply;
        _burn(msg.sender, amount);
        token.transfer(msg.sender, amount);
    }
}

// 充值某项资产，然后拿回某项资产的凭证～
// 比如充值1个ETH，然后返回N个DAI
// ERC4626  一个Vault协议

// 比如A用户充值了一个ETH ,然后该用户充值了多少ETH，需要记录，然后该拿多少share要记录下

// 初始第一步： totalSupply:1000, token.balanceOf(address(this)):1000,充值A用户_amount:1 ,那么 shares = 1*1000/1000 = 1
// 然后_mint函数： totalSupply = 1000+1 = 1001，然后balanceOf【A】= 1，然后给本合约转Token 1

// 第三步： 传入shares = 1,那么 amount = 1*1001/1001 = 1 （比例）
// 然后走burn函数, totalSupply = 1001-1 =1000，balanceOf【A】= 1-1=0，用户取回 token = 1
