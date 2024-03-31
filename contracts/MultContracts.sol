// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContractA {
    address public owner;
    uint256 public value;

    constructor(uint256 _value) {
        owner = msg.sender;
        value = _value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    function updateValue(uint256 _newValue) public onlyOwner {
        value = _newValue;
    }
}

contract ContractB {
    address public owner;
    uint256 secret;
    address public contractAAddress;

    constructor(address _contractAAddress, uint256 _value) {
        owner = msg.sender;
        secret = _value;
        contractAAddress = _contractAAddress;
        require(contractAAddress != address(0), "Invalid contract A address!");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    function updateValue(uint256 _newValue) public onlyOwner {
        secret = _newValue;
    }

    function multiplyByTen() public view returns (uint256) {
        ContractA contractA = ContractA(contractAAddress);
        uint256 value = contractA.value();
        return value * 10;
    }

    function multiplyByFifty() public view returns (uint256) {
        ContractA contractA = ContractA(contractAAddress);
        uint256 value = contractA.value();
        return value * 50;
    }

    function multiplyBySecret() public view returns (uint256) {
        ContractA contractA = ContractA(contractAAddress);
        uint256 value = contractA.value();
        return value * secret;
    }
}
