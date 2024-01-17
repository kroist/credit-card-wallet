// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract GhoMock is ERC20 {
    

    constructor() ERC20("GHO", "GHO") {}

    function mint(address receiver, uint256 amount) public {
        _mint(receiver, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
