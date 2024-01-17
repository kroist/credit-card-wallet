// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


import {IERC3156FlashLender, IERC3156FlashBorrower} from '@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol';

import {GhoMock} from './GhoMock.sol';

contract FlashminterMock is IERC3156FlashLender {

    GhoMock gho;

    bytes32 private constant CALLBACK_SUCCESS = keccak256('ERC3156FlashBorrower.onFlashLoan');

    constructor(
        address _gho
    ) {
        gho = GhoMock(_gho);
    }

    /**
     * @dev The amount of currency available to be lended.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(address token) external view override returns (uint256) {
        return 10000;
    }

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount) external view override returns (uint256) {
        return 0;
    }

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require(token == address(gho), 'FlashMinter: Unsupported currency');

        uint256 fee = 0;
        gho.mint(address(receiver), amount);

        require(
        receiver.onFlashLoan(msg.sender, address(gho), amount, fee, data) == CALLBACK_SUCCESS,
        'FlashMinter: Callback failed'
        );

        gho.transferFrom(address(receiver), address(this), amount + fee);
        gho.burn(amount);
        return true;
    }
}
