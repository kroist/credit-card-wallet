// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {GhoMock} from './GhoMock.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AaveMock {
    
    GhoMock private ghoToken;

    uint256 public borrowed;

    constructor(
        address _ghoToken
    ) payable {
        ghoToken = GhoMock(_ghoToken);
        borrowed = 0;
    }

    function borrow(address to, uint256 amount) public {
        borrowed += amount;
        ghoToken.mint(to, amount);
    }

}
