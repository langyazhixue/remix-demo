
// https://professional-solidity.readthedocs.io/zh-cn/latest/source/13.interface.html#id5
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    // 1个授权
    function approve(address spender, uint256 amount) external returns (bool);

    // 2个事件
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    // 2个交易
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    // 3个查询
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);
}
    

contract ERC20 is IERC20 {
    // 状态变量
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    address public immutable owner;
    // uint256 public immutable totalSupply; // 不增加总量
    uint256 public totalSupply; // 总价总量
    mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;

    // 函数修改器
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 构造函数
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // 1个授权
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 2个交易
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        // msg.sender 也就是当前调用者，是被批准者
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    
    // 1个铸币 - 非必须
    function mint(uint256 amount) external onlyOwner returns (bool) {
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    // 1个销毁 - 非必须
    function burn(uint256 amount) external returns (bool) {
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    // 转移 owner 权限等其他一些操作均是看各自业务，非必需的
}