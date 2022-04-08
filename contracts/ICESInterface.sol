// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


/**
General interface for cross chain transaction between ethereum and solana
*/


interface ICESInterface {
  
  /**
  Init a transaction from Ethereum to Solana
  amount: the amount to be sent to Solana address
  sol_address : Solana address that will receive tokens
   */
  function  createTransaction(
    uint256 amount,
    string memory sol_address // TODO : check if addresses of type Uint256 are compatible with Solana
    //TODO: check if we need a third address
  ) external;

 /**
  Init a transaction from Solana to ethereum supposed to be already confirmed in Solana Blockchain
  amount : number of tokens to be sent to ethereum address
  dest: ethereum receiver address
 */
  function createTransactionReverse(
    uint256 amount
  ) external;


  /**
  Vote for a transaction from Solana to ethereum
  txid : the transaction beneficiary
   */
  function vote(
    address beneficiary
  ) external;


 /**
  claims that a transaction has reached minimum votes to be executed, and make the token transfer to ethereum
  */

  function claim(
  ) external;

/**
register a new voter that will lock 10.000 tokens
 */
  function addVoter(

  ) external;

/**
reports that a voter is cheating. If there are many reports, tokens will be taken from the cheating voter
 voter : the address of voter reported as cheater
 */
  function reportVoter(
    address voter
  ) external;




}
