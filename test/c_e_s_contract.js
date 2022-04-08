const CESContract = artifacts.require("CESContract");

const Token = artifacts.require("Token");

const TruffleAsserts = require("truffle-assertions");



/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CESContract", function ( accounts ) {

  var cesContract;

  var minVotes;

  var maxVotes;

  var heldAddress;

  var minReports;

  var token;

  var collateral;

  var tokenOwner;

  var voters = [] ;

  var reporters = [];

  const totalSupply = 1000000;

  const SOL_ADDRESS = "YOUR_SOL_ADDRESS";


  before("initialize all variable" , async function () {

    token = await Token.new();
    minVotes = 3;
    maxVotes = 4;
    heldAddress = accounts[1];
    minReports = 2;
    collateral = 10000;
    tokenOwner = accounts[0];
    for (let i = 2; i< 7; i++) {
      voters.push(accounts[i]);
    }

    for (let i = 8; i< 10; i++) {
      reporters.push(accounts[i]);
    }

    cesContract = await CESContract.new(
      token.address,
      minVotes,
      maxVotes,
      minReports,
      heldAddress,
      collateral
    );



  })


  it("check that all variables are initialized well", async function () {
    let balance = await token.balanceOf(tokenOwner);
    assert.equal(balance , totalSupply);
    
  });

  it("test add a voter", async function () {
    let voter = voters[0];
    await token.transfer(voter, collateral);
    await token.approve(cesContract.address , collateral , {from: voter});
    await cesContract.addVoter({from : voter});
    let isVoter = await cesContract.isVoter(voter);
    assert.isTrue(isVoter);
    
  });

  it("try to add a voter that does not have miniumum balance", async function () {
    let voter = voters[1];
    await token.transfer(voter, collateral - 1 );
    await token.approve(cesContract.address , collateral - 1, {from: voter});
    
   await TruffleAsserts.reverts(
     cesContract.addVoter({from : voter}),
    "" , ""); // XXX check why message is not considered
  });

  it("try to add a voter that's already exists", async function () {
    let voter = voters[0];
    await token.transfer(voter, collateral  );
    await token.approve(cesContract.address , collateral, {from: voter});
    
    await TruffleAsserts.reverts(
     cesContract.addVoter({from : voter}),
    "" , "");
  });

  it ("create transaction " , async function () {

    await token.approve(cesContract.address , 20, {from: tokenOwner});
    
    let tx = await cesContract.createTransaction(20 , SOL_ADDRESS , {from: tokenOwner });

    let logs = tx.logs[2];
    let event = logs.event;
    let amount = logs.args[0];
    let sol_address = logs.args[1];

    assert.equal(event , "transactionCreated");
    assert.equal(amount , 20);
    assert.equal(sol_address , SOL_ADDRESS );

    
  }); 


  it ("create transaction without having a balance" , async function () {

    await TruffleAsserts.reverts( cesContract.createTransaction(20 , SOL_ADDRESS , {from: tokenOwner }) , "", "");
    
  }); 




});
