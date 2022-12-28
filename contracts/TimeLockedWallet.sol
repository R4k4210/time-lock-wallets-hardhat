// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ERC20.sol";

contract TimeLockedWallet {
    address public creator;
    address public owner;
    uint256 public unlockDate;
    uint256 public createdAt;

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(
        address _creator,
        address _owner,
        uint256 _unlockDate
    ) payable {
        creator = _creator;
        owner = _owner;
        unlockDate = _unlockDate;
        createdAt = block.timestamp;
    }

    // fallback() external payable {
    //     emit Received(msg.sender, msg.value);
    // }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function info()
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (creator, owner, unlockDate, createdAt, address(this).balance);
    }

    function withdraw() public onlyOwner {
        require(block.timestamp >= unlockDate);
        payable(msg.sender).transfer(address(this).balance);
        emit Withdrew(msg.sender, address(this).balance);
    }

    function withdrawTokens(address _tokenContract) public onlyOwner {
        require(block.timestamp >= unlockDate);
        ERC20 token = ERC20(_tokenContract);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(owner, tokenBalance);
        emit WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }
}
