// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
a token created only for test purposes
 */
contract Token is ERC20  {
  constructor() ERC20("USDT", "usd")
   {
     // the contract deployer will have 1 million token
     _mint(msg.sender, 1000_000);
  }
}
