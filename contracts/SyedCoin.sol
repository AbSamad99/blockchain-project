// contracts/SyedCoin.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts@v4.9.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@v4.9.3/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts@v4.9.3/token/ERC20/extensions/ERC20Burnable.sol";

contract SyedCoin is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;

    // Check which makes sure only the owner can run the function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(
        uint256 cap,
        uint256 reward
    )
        ERC20("SyedCoin", "SCN") // Our coin name and symbol
        ERC20Capped(cap * (10 ** decimals())) // This 'class' is used to implement the max coin/token capping
    {
        owner = payable(msg.sender); // Setting the owner as the person who deployed the contract, aka ourselves
        _mint(owner, ((cap * 60) / 100) * (10 ** decimals())); // Giving ourselves 60% of the coins
        blockReward = reward * (10 ** decimals()); // Setting the block reward
    }

    function _mint(
        address account,
        uint256 amount
    ) internal virtual override(ERC20Capped, ERC20) {
        require(
            ERC20.totalSupply() + amount <= cap(),
            "ERC20Capped: cap exceeded"
        );
        super._mint(account, amount);
    }

    // Reward will be paid to whoever solves the block containing the token transfer transaction
    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    // Hook which allows us to pay the
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (
            from != address(0) &&
            to != block.coinbase &&
            block.coinbase != address(0) &&
            ERC20.totalSupply() + blockReward <= cap()
        ) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }

    // In case we ever want to change the block reward in the future
    function setBlockReward(uint256 reward) public onlyOwner {
        blockReward = reward * (10 ** decimals());
    }

    // Destroy the contract for whatever reason
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}
