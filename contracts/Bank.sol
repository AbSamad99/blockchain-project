// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

/// @title Banking Applicaion

contract Bank {
    struct TransferRequest {
        address to;
        uint256 amount;
    }

    struct Account {
        string name;
        uint256 balance;
        address accountNumber;
        TransferRequest[] transferRequests;
    }

    address bankManager;
    mapping(address => Account) accounts;
    address[] public activeAccounts;

    constructor() {
        bankManager = msg.sender;
    }

    modifier onlyBankManager() {
        require(
            msg.sender == bankManager,
            "Only the bank manager can call this function"
        );
        _;
    }

    // Makes sure account exists
    modifier requireAccount() {
        require(
            bytes(accounts[msg.sender].name).length != 0,
            "Account does not exist!"
        );
        _;
    }

    // Makes sure account does not exist
    modifier requireNoAccount() {
        require(
            bytes(accounts[msg.sender].name).length == 0,
            "Account already exists!"
        );
        _;
    }

    modifier performBalanceCheck(uint256 amount) {
        require(
            accounts[msg.sender].balance >= amount,
            "Insufficient balance!"
        );
        _;
    }

    modifier validateTransferReqIndex(uint256 index) {
        require(
            index < accounts[msg.sender].transferRequests.length,
            "No transfer request at that index!"
        );
        _;
    }

    modifier checkSameAccount(address addressToCheck) {
        require(
            msg.sender != addressToCheck,
            "Cannot make request to yourself!"
        );
        _;
    }

    // Open your new account
    function openAccount(string calldata name) public requireNoAccount {
        require(
            bytes(name).length >= 5,
            "Name must be at least 5 characters long!"
        );
        accounts[msg.sender].name = name;
        accounts[msg.sender].balance = 0;
        accounts[msg.sender].accountNumber = msg.sender;
        activeAccounts.push(msg.sender);
    }

    // Add funds to your account
    function addFunds() public payable requireAccount {
        require(msg.value % 1000 == 0, "Amount has to be a multiple of 1000!");
        uint256 amountToBeAdded = msg.value / 1000;
        accounts[msg.sender].balance += amountToBeAdded;
    }

    // Withdraw funds from your account
    function withdrawFunds(
        uint256 amount
    ) public requireAccount performBalanceCheck(amount) {
        (bool sent, ) = msg.sender.call{value: amount * 1000}("");
        require(sent, "Failed to withdraw funds!");
        accounts[msg.sender].balance -= amount;
    }

    // Check the balance in your account
    function checkBalance() public view requireAccount returns (uint256) {
        return accounts[msg.sender].balance;
    }

    // Transfers funds to a different account
    function transferFunds(
        address to,
        uint256 amount
    ) public requireAccount performBalanceCheck(amount) checkSameAccount(to) {
        require(
            bytes(accounts[to].name).length != 0,
            "Recipient account does not exist!"
        );
        accounts[msg.sender].balance -= amount;
        accounts[to].balance += amount;
    }

    // Request transfer of funds from another account
    function requestFunds(
        address from,
        uint256 amount
    ) public requireAccount checkSameAccount(from) {
        require(
            bytes(accounts[from].name).length != 0,
            "Requested account does not exist!"
        );
        accounts[from].transferRequests.push(
            TransferRequest({to: msg.sender, amount: amount})
        );
    }

    // Check the number of transfer requests made to your account
    function checkTransferReqNum()
        public
        view
        requireAccount
        returns (uint256)
    {
        return accounts[msg.sender].transferRequests.length;
    }

    // Check transfer request details by index
    function checkTransferReqDetails(
        uint256 index
    )
        public
        view
        requireAccount
        validateTransferReqIndex(index)
        returns (TransferRequest memory)
    {
        return accounts[msg.sender].transferRequests[index];
    }

    // Approve transfer request by index
    function approveTransferRequest(
        uint256 index
    ) public requireAccount validateTransferReqIndex(index) {
        TransferRequest storage request = accounts[msg.sender].transferRequests[
            index
        ];
        transferFunds(request.to, request.amount);
        uint256 lastIndex = accounts[msg.sender].transferRequests.length - 1;
        accounts[msg.sender].transferRequests[index] = accounts[msg.sender]
            .transferRequests[lastIndex];
        accounts[msg.sender].transferRequests.pop();
    }

    // Close your account and then transfer your balance as wei to your address
    function closeAccount() public requireAccount {
        uint256 balance = accounts[msg.sender].balance;
        delete accounts[msg.sender];
        if (balance > 0) {
            (bool sent, ) = msg.sender.call{value: balance * 1000}("");
            require(sent, "Failed to transfer balance to account holder!");
        }

        for (uint256 i = 0; i < activeAccounts.length; i++) {
            if (activeAccounts[i] == msg.sender) {
                activeAccounts[i] = activeAccounts[activeAccounts.length - 1];
                activeAccounts.pop();
                break;
            }
        }
    }

    // Close the bank
    // function closeBank() public onlyBankManager {
    //     for (uint i = 0; i < activeAccounts.length; i++) {
    //         address accountAddress = activeAccounts[i];
    //         uint balance = accounts[accountAddress].balance;
    //         (bool sent, ) = accountAddress.call{value: balance * 1000}("");
    //         require(sent, "Failed to transfer balance to account holder");
    //     }
    //     selfdestruct(payable(bankManager));
    // }
}
