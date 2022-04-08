// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './ICESInterface.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract CESContract is ICESInterface , ERC20 {

  address token_type;


  mapping(address => mapping (address => bool)) votes;
  mapping(address => mapping (uint => address)) tx_voters;
  // number of votes per address
  mapping(address => uint ) vote_count;

  mapping(address => bool) voters;

  mapping(address => mapping( address => bool)) reports;

  mapping(address => uint) report_counts;

  mapping(address => bool) black_list;

  // minimum votes per transactions
  uint min_votes;

  // maximum votes per transactions
  uint max_votes;

  // minimum reports to blacklist a user
  uint min_reports;

  // the account that will take tokens of the voter if the latter reached minimum reports
  address held_account;

  // minimum tokens to become a voter
  uint collateral;

  constructor(address token , uint min , uint max,uint min_r , address held_a , uint collateral_amount) 
  ERC20("CES", "CES")
   {
     token_type = token;
     min_votes = min;
     max_votes = max;
     min_reports = min_r;
     held_account = held_a;
     collateral = collateral_amount;
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
    uint256 amount
    ) external {
    require(balanceOf(msg.sender) == 0 , "Transaction already pending" );
    _mint(msg.sender , amount);
  }

  function vote(
    address beneficiary
  ) external {
    require(voters[msg.sender] == true , "Not registred voter" );
    require(votes[beneficiary][msg.sender] == false, "already voted by same voter");
    uint count = vote_count[beneficiary];
    require(count <= max_votes , "Maximum number of votes has been reached");
    votes[beneficiary][msg.sender] = true;
    vote_count[beneficiary] = count +1;
    tx_voters[beneficiary][count] = msg.sender;
    
  }

  function claim(
  ) external {
   uint count = vote_count[msg.sender];
   require(count >= min_votes , "more votes are required to claim transaction");
   uint prebalance = balanceOf(msg.sender);
   uint fees = prebalance * 100 / 5;

   // distribute rewards to voters
   uint reward = fees / count;
   for (uint i = 0 ; i < count ; i++) {
     IERC20(token_type).transfer(tx_voters[msg.sender][i], reward);
     delete votes[msg.sender][tx_voters[msg.sender][i]];
     delete tx_voters[msg.sender][i];
   }

   _burn(msg.sender , prebalance);
   IERC20(token_type).transfer(msg.sender, prebalance - fees);
   delete vote_count[msg.sender];
   
  }


  function addVoter(
  ) external {
    require(voters[msg.sender] == false , "voter already registred");
    require(black_list[msg.sender] == false , "voter had been blacklisted");
    IERC20(token_type).transferFrom(msg.sender, address(this), collateral);
    voters[msg.sender] = true;
  }


  function reportVoter(
    address voter
  ) external {
    // only a voter can report another voter
    require(voters[msg.sender] == true , "Not registred voter" );
    require(reports[voter][msg.sender] == false , "Already reported by this voter");

    reports[voter][msg.sender] = true;
    uint count = report_counts[voter];
    if (count >= min_reports) {
      voters[voter] = false;
      black_list[voter] = true;
      IERC20(token_type).transfer(held_account, collateral); //FIXME : Reporters must get tokens
    }

    //XXX : we have to manage transactions that have already executed and voted wrongly
  }

  /**
  displays number of voters per beneficiary
   */
  function voterCount(address beneficiary) public view returns (uint) {
   return vote_count[beneficiary];
  }
  /**
  checks if a voter is registred
   */
  function isVoter(address voter_address) public view returns (bool) {
    return voters[voter_address];
  }

  /**
    displays number of reports per voter
  */

  function reportCount(address voter) public view returns (uint) {
    return report_counts[voter];
  }

  /**
  checks if beneficiary can claim transaction
  */

  function canClaim(address beneficiary) public view returns(bool) {
     uint count = vote_count[beneficiary];
     return count >= min_votes;
  }

  /**
  checks if a voter is black listed
  */

  function isBlackListed(address voter_address) public view returns (bool) {
    return black_list[voter_address];
  }

}
