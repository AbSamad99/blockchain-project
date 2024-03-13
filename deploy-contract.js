var deployedContract = contract.new({
  data: bytecode,
  from: eth.accounts[0],
});

while (eth.getTransactionReceipt(deployedContract.transactionHash) === null) {
  // Wait for the transaction to be mined
}

var contractAddress = eth.getTransactionReceipt(
  deployedContract.transactionHash
).contractAddress;

var instance = contract.at(contractAddress);
