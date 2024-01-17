// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC3156FlashLender, IERC3156FlashBorrower} from '@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract WalletGHOFlashminter {

    IERC3156FlashLender private flashMinter;
    address private ghoToken;

    constructor(
        address flashMinterAddress,
        address _ghoToken
    ) payable {
        flashMinter = IERC3156FlashLender(flashMinterAddress);
        ghoToken = _ghoToken;
    }

    function getFlashloan(uint256 amount) public {
        flashMinter.flashLoan(
            IERC3156FlashBorrower(msg.sender),
            ghoToken,
            amount,
            ""
        );
    }

}
