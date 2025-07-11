// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// import './Context.sol';

contract MyToken2 {

    // - 1、代币信息 -

    // 代币名称 name
    string private _name;
    // 代币标识 symbol
    string private _symbol;
    // 代币小数位数 decimals
    uint8 private _decimals;
    // 代币的总发行量 totalSupply
    uint256 private _totalSupply;
    // 代币数量 balance
    mapping(address => uint256) private _balances;
    // 授权代币数量 allowance
    mapping(address => mapping(address => uint256)) private _allowances;


    function _msgSender() internal view returns(address) {
        return msg.sender;
    }

    // - 2、初始化 - 
    constructor () {
        _name = "RabbitCoin6";
        _symbol = "RABTC6";
        _decimals = 18;

        // 初始化货币池
        _mint(_msgSender(), 100 * 10000 * 10**_decimals);
    }

    

    // - 3、取值器 -
    
    // 返回代币的名字 name()
    function name() public view returns (string memory) {
        return _name;
    }
    // 返回代币标识 symbol()
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    // 返回代币的小数位数 decimals()
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    // 返回代币总发行量 totalSupply()
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    // 返回账户拥有的代币数量 balanceOf()
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    // 返回授权代币数量 allowanceOf()
    function allowanceOf(address owner, address spender) public view returns(uint256) {
        return _allowances[owner][spender];
    }

    // - 4、函数 -

    // 代币转发
    function transfer(address to, uint256 amount) public returns (bool) {
        // 当前账号，是变化的。
        address owner = _msgSender();
        // 实现转账
        _transfer(owner, to, amount);
        return true;
    }

    // 授权代币的转发
    function approve(address spender, uint256 amount) public returns (bool) {
        // 银行授权给我（银行要贷款给我）
        address owner = _msgSender();
        // owner 是授权人
        // spender 被授权人
        _approve(owner, spender, amount);
        return true;
    }

    // 授权代币转发。授权人执行，从银行账户里提钱给我。
    // 贷款人（银行）授权我（中介公司）提钱
    // 我（中介公司）提钱给我自己（买房人）
    // 我（中介公司）提钱给房屋出售者
    // 我（中介公司）提钱给中介公司
    // 我（中介公司）提钱给银行
    // A 授权给B 100块钱，然后 B 可以 从A 账户赚钱 给C 比如50 ，从A账户转账给C 50块钱
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address owner = _msgSender();

        // 更新授权账户信息
        _spendAllowance(from, owner, amount);

        // 执行转账
        // from: 银行
        // to: 我自己，中介公司，买房人
        _transfer(from, to, amount);
        return true;
    }

    
    
    // - 5、事件 -
    event Transfer(address from, address to, uint256 amount);
    event Approval(address owner, address spender, uint256 amount);

    // - 6、合约内部函数 - 
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        // 初始化货币数量
        _totalSupply += amount;
        // 给某个账号注入起始资金
        unchecked {
            _balances[account] += amount;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, unicode"ERC20: 余额不足。");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve from the zero address");
        // 执行授权
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowanceOf(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, unicode"ERC20: 余额不足");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /* 
        主体：借款人，贷款人，中介公司，房屋出售者 account
        授权：贷款人（银行）借钱给我 approve  100w
        提款：从银行贷款账户里提钱给自己 transferFrom 1w
        支付房款：借款人转账给房屋出售者 transferFrom 90w
        支付佣金：借款人转账中介公司 transferFrom 9w
     */

    /* 
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

        {
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4: {
                0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2: 100w
            },
            
            0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db: {
                0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB: 200w
            }
        }
     */
}
/// 0x6975476f2ee985D9D04a180ce090651BaB645a5C
/// 0x667D0F43494b6B4fDd3527F0dF3eC565F0727acF
/// 0x92e2aE86d117F67c85d019d2718C9EBEac766093