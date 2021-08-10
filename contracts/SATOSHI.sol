// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import './interfaces/ISATOSHI.sol';
import "./interfaces/ISatsFlashBorrower.sol";

import "hardhat/console.sol";

contract BorrowerProxy {
    address satoshi;
    constructor() public { satoshi = msg.sender; }

    function lend(address _caller, bytes calldata _data) external payable {
        require(msg.sender == satoshi, "BorrowerProxy: Caller is not SATOSHI");
        (bool success, ) = _caller.call{ value: msg.value }(_data);
        require(success, "BorrowerProxy: Borrower contract reverted during execution"); 
    }
}

contract SATOSHI is ERC20, ISATOSHI, ReentrancyGuard {
    using SafeMath for uint;

    // state variables
    uint private _100m = 1e8; // 100M 
    uint private DECIMAL_18 = 1e18;
    uint private DECIMAL_27 = 1e27;

    uint MAX_INT = 2**256 - 1;
    uint ceiling;
    bytes32 public constant CALLBACK_SUCCESS_SATS = keccak256("ISatsFlashBorrower.onSatsFlashLoan");

    BorrowerProxy public borrower;
    address public borrower_ads;

    // Events
    event DepositRBTC(uint sats_amt, address _user);
    event WithdrawRBTC(uint sats_amt, address _user);
    event FlashBTC(uint _amount, address _borrower);
    event FlashMintSATS(uint _amount, address _borrower);

    // Constructor
    constructor() public ERC20('SATOSHI', 'SATS') {
        borrower = new BorrowerProxy();
        borrower_ads = address(borrower);
    }

    // Get Functions
    function getRBTCBalance() public override view returns(uint) {
        return address(this).balance;
    }

    function getSATSandRBTCratio() public override view returns(uint) {
        return totalSupply().mul(DECIMAL_18).div(_100m).div(getRBTCBalance());
    }

    // Flashmintable SATS is limited to the one tenth of the totalsupply
    function getCeiling() public override view returns(uint) {
        return totalSupply().div(10);
    }

    // Deposit 1
    function depositRBTC() public payable override nonReentrant {
        uint sats_amt = msg.value.mul(_100m);
        _mint(msg.sender, sats_amt);

        emit DepositRBTC(sats_amt, msg.sender);
    }

    // Deposit 2
    function depositRBTCto(address _user) public payable override nonReentrant {
        uint sats_amt = msg.value.mul(_100m);
        _mint(_user, sats_amt);

        emit DepositRBTC(sats_amt, _user);
    }

    // Withdraw 1
    function withdrawRBTC(uint sats_amt) public override nonReentrant {
        require(sats_amt <= balanceOf(msg.sender), "SATOSHI: Not enough balance");

        uint btc_atm = sats_amt.mul(address(this).balance).div(totalSupply()); 

        _burn(msg.sender, sats_amt);
        (bool success, ) = msg.sender.call{ value: btc_atm }("");
        require(success, "SATOSHI: Couldn't transfer BTC");

        emit WithdrawRBTC(sats_amt, msg.sender);
    }

    // Withdraw 2
    function withdrawRBTCto(uint sats_amt, address _user) public override nonReentrant {
        require(sats_amt <= balanceOf(msg.sender), "SATOSHI: Not enough balance");

        uint btc_atm = sats_amt.mul(address(this).balance).div(totalSupply()); 

        _burn(msg.sender, sats_amt);
        (bool success, ) = _user.call{ value: btc_atm }("");
        require(success, "SATOSHI: Couldn't transfer BTC");

        emit WithdrawRBTC(sats_amt, _user);
    }

    // Flashloan 1
    function flashBTC(uint _amount, bytes calldata _data) external override payable nonReentrant {
        require(_amount > 0, "SATOSHI: Amount Zero");
        
        uint initial_balance = address(this).balance;
        require(_amount <= initial_balance, "SATOSHI: _amount exceeds the borrowable limit; RBTC in the contract");
        
        (bool success, ) = msg.sender.call{ value: _amount }("");
        require(success, "SATOSHI: Couldn't transfer BTC");
        borrower.lend(msg.sender, _data); //

        uint final_balance = address(this).balance; 

        require(final_balance >= initial_balance, "SATOSHI: Borrower failed to return the borrowed RBTC");

        emit FlashBTC(_amount, msg.sender);
    }

    // Flashmint SATS and burn ( payback )
    function flashMintSATS(ISatsFlashBorrower _borrower, uint _amount, bytes calldata _data) external override nonReentrant returns(bool) {
        require(_amount > 0, "SATOSHI: Amount Zero");
        ceiling = getCeiling();
        require(_amount <= ceiling, "SATOSHI: Amount exceeds the limit");

        console.log("totalsupply1", totalSupply());
        _mint(address(_borrower), _amount);
        console.log("totalsupply2", totalSupply());
        require(_borrower.onSatsFlashLoan(address(_borrower), _amount, _data) == CALLBACK_SUCCESS_SATS, "SATOSHI: Callback Failed");
        console.log("totalsupply3", totalSupply());
        _burn(address(_borrower), _amount);
        console.log("totalsupply4", totalSupply());

        emit FlashMintSATS(_amount, address(_borrower));
        return true;
    }

    // Fallback
    // Don't send/transfer RBTC directly into this contract because receive() doesn't allow it. 
    // If you do so, deposited RBTC in the contract will be lost and shared in SATS holders.
    receive() external payable {}
}

/*

* Flashloan & FlashMint References

-MakerDAO, DAI FlashMint:
https://mips.makerdao.com/mips/details/MIP25, 
https://github.com/makerdao/dss-flash/blob/master/src/flash.sol

-Aave Flashbox
https://github.com/aave/flashloan-box/tree/master/contracts

-Fifikobayashi
https://github.com/fifikobayashi/FlashMintArbitrage

-Openzeppelin
https://blog.openzeppelin.com/flash-mintable-asset-backed-tokens/
https://forum.openzeppelin.com/t/release-candidate-for-contracts-4-1/7075

-EIP3156
https://eips.ethereum.org/EIPS/eip-3156
https://ethereum-magicians.org/t/erc-3156-flash-loans-review-discussion/5077

-WETH10
https://github.com/WETH10/WETH10/blob/main/contracts/WETH10.sol

-Austin Williams
https://github.com/Austin-Williams/flash-mintable-tokens/blob/master/FlashWETH/FlashWETH.sol
https://etherscan.io/address/0xf7705C1413CffCE6CfC0fcEfe3F3A12F38CB29dA

*/

