// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC3156FlashBorrower} from '@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol';

import {WalletGHOFlashminter} from './WalletGHOFlashminter.sol';
import {AaveMock} from './AaveMock.sol';

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Wallet is IERC3156FlashBorrower {

    uint256 private constant FLASH_AMOUNT = 1000;
    
    IERC20 private ghoToken;
    WalletGHOFlashminter private walletFlashminter;
    address private flashmintFacilitator;
    AaveMock private aave;
    bytes32 private constant CALLBACK_SUCCESS = keccak256('ERC3156FlashBorrower.onFlashLoan');

    address private transfer_to;
    uint256 private transfer_amount;

    constructor(
        address _ghoToken,
        address _walletFlashminter,
        address _flashmintFacilitator,
        address _aave
    ) payable {
        ghoToken = IERC20(_ghoToken);
        walletFlashminter = WalletGHOFlashminter(_walletFlashminter);
        flashmintFacilitator = _flashmintFacilitator;
        aave = AaveMock(_aave);
    }

    function transferGho(address to, uint256 amount) public {
        transfer_to = to;
        transfer_amount = amount;
        walletFlashminter.getFlashloan(FLASH_AMOUNT);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(initiator == address(walletFlashminter));
        require(token == address(ghoToken));

        ghoToken.transfer(transfer_to, transfer_amount);

        uint256 haveGhoAmount = ghoToken.balanceOf(address(this));
        uint256 toBorrowGhoAmount = amount + fee - haveGhoAmount;
        if (toBorrowGhoAmount > 0) {
            // borrow from aave
            aave.borrow(address(this), toBorrowGhoAmount);
        }
        ghoToken.approve(flashmintFacilitator, amount+fee);

        return CALLBACK_SUCCESS;
    }
}
