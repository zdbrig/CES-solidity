// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './ICESInterface.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract CESContract is ICESInterface , ERC20 {

  address token_type;


  mapping(address => mapping (address => bool)) votes;

  mapping(address => bool) voters;

  mapping(address => mapping( address => bool)) reports;


  constructor(address token) 
  ERC20("CES", "CES")
   {
     token_type = token;
   
  }

  event transactionCreated(uint256 amount, string sol_address);


  function  createTransaction(
    uint256 amount,
    string memory sol_address 
  ) external {
       IERC20(token_type).transferFrom(msg.sender, address(this), amount);
       emit transactionCreated(amount, sol_address);
  }


  function createTransactionReverse(
    uint256 amount,
    address dest //FIXME: this parameter can be taken out, and use msg.sender
  ) external {
    require(balanceOf(dest) == 0 , "Transaction already pending" );
    _mint(dest , amount);
  }

  function vote(
    address beneficiary
  ) external {
    require(voters[msg.sender] == true , "Not registred voter" );
    //TODO: check if maximum number of votes has been already reached
    votes[beneficiary][msg.sender] = true;

    
  }

  function claim(
    address beneficiary
  ) external {
   // TODO: check that the number of votes reached 5
   // TODO: ditribute 5% of amount to voters
   uint prebalance = balanceOf(beneficiary);
   uint fees = prebalance * 100 / 5;
   _burn(beneficiary , prebalance);
   IERC20(token_type).transfer(address(this), prebalance - fees);
   //TODO: clean previous votings
  }


  function addVoter(
  ) external {
    require(voters[msg.sender] == false , "voter already registred");
    IERC20(token_type).transferFrom(msg.sender, address(this), 10000);
    voters[msg.sender] = true;
  }


  function reportVoter(
    address voter
  ) external {
    require(voters[msg.sender] == true , "Not registred voter" );
    reports[voter][msg.sender] = true;

    //TODO : check if we reached 50 reports to reduce token amounts to that voter

    //TODO : we have to manage transactions that have already executed and voted wrongly
  }
}
