// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TimeLockedWallet.sol";

contract TimeLockedWalletFactory {
    mapping(address => address[]) wallets;

    function getWallets(address _user) public view returns (address[] memory) {
        return wallets[_user];
    }

    function newTimeLockedWallet(address _owner, uint256 _unlockDate)
        public
        payable
    {
        TimeLockedWallet wallet = new TimeLockedWallet(
            msg.sender,
            _owner,
            _unlockDate
        );

        address newWallet = address(wallet);

        wallets[msg.sender].push(newWallet);
        if (msg.sender != _owner) {
            wallets[_owner].push(newWallet);
        }

        payable(newWallet).transfer(msg.value);

        emit Created(
            newWallet,
            msg.sender,
            _owner,
            block.timestamp,
            _unlockDate,
            msg.value
        );
    }

    // Prevents accidental sending of ether to the factory
    receive() external payable {
        revert();
    }

    event Created(
        address wallet,
        address from,
        address to,
        uint256 createdAt,
        uint256 unlockDate,
        uint256 amount
    );
}
