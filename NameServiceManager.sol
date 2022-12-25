// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// Task
/// Register and maintain a domain service for an address
/// Add records to the user's domain ID
/// Fetch the records and mapping when needed

import {StringUtils} from "./libraries/StringUtils.sol";

contract Domains {
    address payable public owner;

    // Domain struct
    struct Domain {
        string domainName;
        uint256 pricePaid;
        address owner;
        string record;
        bool registered;
        string twitter;
    }

    // mapping from domain name --> domain details
    mapping(string => Domain) public domains;
    mapping(address => string[]) public domainsRegistered;

    event domainRegistered(string _name, address owner, uint256 _price);
    event recordAdded(string _name, string _record);
    event twitterAdded(string _name, string _twitter);

    string public tld;

    constructor(string memory _tld) payable {
        owner = payable(msg.sender);
        tld = _tld;
    }

    modifier onlyDomainOwner(string memory _name) {
        require(
            domains[_name].owner == msg.sender,
            "You are not the domain owner "
        );
        _;
    }

    /// function to determine the price for the domain
    function price(string calldata name) public pure returns (uint256) {
        uint256 len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 10 * 10**15;
        } else if (len == 4) {
            return 5 * 10**15;
        } else {
            return 3 * 10**15;
        }
    }

    // register function adding the name to the mapping we creater
    function register(string calldata name) public payable {
        require(!domains[name].registered, "Already registered");

        /// calculate the price first for the name registeration
        uint256 _price = price(name);
        require(msg.value >= _price, "Not Enough Matic paid");

        // Combine the name passed into the function  with the TLD
        string memory _name = string(abi.encodePacked(name, ".", tld));

        domains[name] = Domain(name, _price, msg.sender, "", true, "");
        domainsRegistered[msg.sender].push(name);

        emit domainRegistered(name, msg.sender, _price);
    }

    // set record function
    function setRecord(string calldata _name, string calldata _record)
        public
        onlyDomainOwner
    {
        domains[_name].record = _record;
        emit recordAdded(_name, _record);
    }

    // set record function
    function setTwitter(string calldata _name, string calldata _twitter)
        public
        onlyDomainOwner
    {
        domains[_name].twitter = _twitter;
        emit twitterAdded(_name, _twitter);
    }

    // domain owner's address
    function getAddress(string calldata name) public view returns (address) {
        return domains[name].owner;
    }

    function getRecord(string calldata name)
        public
        view
        returns (string memory)
    {
        return domains[name].record;
    }

    function getTwitter(string calldata name)
        public
        view
        returns (string memory)
    {
        return domains[name].twitter;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of the contract");
        _;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }

    /// @dev Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit received(msg.sender, msg.value);
    }

    /// @dev Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
