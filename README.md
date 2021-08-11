# Overview

SATS(SATOSHI Token) is a "stablecoin" which 1 SATS is always pegged to one hundred millionth of 1 Bitcoin. <br>
SATS is mintable and redeemable against RBTC(Rsk Smart Bitcoin) on RSK blcokchain.

## Motivation
Some say "BTC is too expensive". So this is the "cheaper" BTC even they can buy and stack easily.

## Features
- RBTC held in the SATOSHI contract is flashlonable.
- 10% of the totalsupply of SAT is flashmintable.

Flashloan function is bulit by forking keeperdao's codes and Flashmint is built based on EIP3156 implementation.

## Note:
- Don't send your RBTC and SATS direcly into the SATOSHI token contract. Funds will be lost.
- Not audited. use at your own risk with a small fund.

## Deployment

RSK Testnet: [`0x3150007C61a11C4124dBd08E35AeB812C6A2D036`](https://explorer.testnet.rsk.co/address/0x3150007c61a11c4124dbd08e35aeb812c6a2d036)

## Build ( hardhat )

1- install dependencies : `npm install` <br>
2- compile : `npx hardhat compile`<br>
3- test : `npx hardhat test`<br>
4- deploy : `npx hardhat run --network localhost scripts_deploy/deploy.js`<br>


### References about Flash loan & Flash mint

KeeperDAO flashloan example:<br>
-https://github.com/keeperdao/example

MakerDAO DAI FlashMint:<br>
-https://mips.makerdao.com/mips/details/MIP25<br>
-https://github.com/makerdao/dss-flash/blob/master/src/flash.sol

Aave Flashbox:<br>
-https://github.com/aave/flashloan-box/tree/master/contracts

Fifikobayashi:<br>
-https://github.com/fifikobayashi/FlashMintArbitrage

Openzeppelin:<br>
-https://blog.openzeppelin.com/flash-mintable-asset-backed-tokens/<br>
-https://forum.openzeppelin.com/t/release-candidate-for-contracts-4-1/7075

EIP3156:<br>
-https://eips.ethereum.org/EIPS/eip-3156<br>
-https://ethereum-magicians.org/t/erc-3156-flash-loans-review-discussion/5077

WETH10:<br>
-https://github.com/WETH10/WETH10/blob/main/contracts/WETH10.sol

Austin Williams:<br>
-https://github.com/Austin-Williams/flash-mintable-tokens/blob/master/FlashWETH/FlashWETH.sol <br>
-https://etherscan.io/address/0xf7705C1413CffCE6CfC0fcEfe3F3A12F38CB29dA
