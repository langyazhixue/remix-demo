// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC4626 is ERC20, IERC4626 {
    // 金库的基础资产代币
    ERC20 private immutable _asset;
    constructor(
        ERC20 asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = asset_;
    }
    // 返回基础代币的地址
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }
    // 就买1块钱，不管返回多少的shares
    function deposit(
        uint256 assets,
        address receiver
    ) public virtual returns (uint256 shares) {
        // receiver 可以充值给另外地址
        // 利用 previewDeposit() 计算将获得的金库份额
        shares = previewDeposit(assets);

        // 先 transfer 后 mint，防止重入
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // 用户就买多少shares，然后看要充多少基础代币
    function mint(
        uint256 shares,
        address receiver
    ) public virtual returns (uint256 assets) {
        // 利用 previewMint() 计算需要存款的基础资产数额
        assets = previewMint(shares);

        // 先 transfer 后 mint，防止重入
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // 
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        // 利用 previewWithdraw() 计算将销毁的金库份额
        shares = previewWithdraw(assets);

        // 如果调用者不是 owner，则检查并更新授权
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // 先销毁后 transfer，防止重入，一般 owner 等于操作者自己
        _burn(owner, shares);
        // 从合约valut02 转入 = assets 的基础代币给 receiver
        _asset.transfer(receiver, assets);

        // 释放 Withdraw 事件
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    // C把A的share给兑出来，冲给receiver 
    // 通过shares,返回要赎回的基础代币资产
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        // 利用 previewRedeem() 计算能赎回的基础资产数额
        assets = previewRedeem(shares);

        // 如果调用者不是 owner，则检查并更新授权
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // 先销毁后 transfer，防止重入
        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        // 释放 Withdraw 事件
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    // 返回金库管理的基础代币总额
    function totalAssets() public view virtual returns (uint256) {
        // 返回合约中基础资产持仓
        return _asset.balanceOf(address(this));
    }

    //核心方法 assets -> shares 数量估计
    function convertToShares(
        uint256 assets
    ) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 铸造金库份额
        // 如果 supply 不为0，那么按比例铸造
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }

    // 核心方法  shares -> assets 数量估计，我要拿到这么多的shares,然后要充多少钱进来
    function convertToAssets(
        uint256 shares
    ) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // 如果 supply 为 0，那么 1:1 赎回基础资产
        // 如果 supply 不为0，那么按比例赎回
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }

    // 通过输入基础代币，看可以获得多少shares
    function previewDeposit(
        uint256 assets
    ) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    // 通过输入shares, 看可以返回多少基础代币
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    // 通过输入基础代币，看可以获得多少shares
    function previewWithdraw(
        uint256 assets
    ) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    // 通过输入shares, 看可以返回多少基础代币
    function previewRedeem(
        uint256 shares
    ) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    //最大的充值量，充多少基础代币，获得多少的shares 
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    // 最大的可获得shares量
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    
    // 最大的可以取回的基础金币总量
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }

    // 最大的可以获得的shares总量
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }
}

// slippage 滑点～～～