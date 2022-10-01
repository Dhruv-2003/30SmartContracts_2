// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract AccessControl {
    /// mapping from role > account > bool
    mapping(bytes32 => mapping(address => bool)) public roles ;
    event GrantRole(bytes32 indexed role , address indexed account);
    event RevokeRole(bytes32 indexed role , address indexed account);
    
    /// we tagged them as constant we don't want anyone to change the role
    bytes32 private constant ADMIN = keccak256(abi.encodePacked(("ADMIN")));
    bytes32 private constant USER = keccak256(abi.encodePacked(("USER")));
    bytes32 private constant MODERATOR = keccak256(abi.encodePacked(("MODERATOR")));

    // user need to pass the bytes form of the role
    constructor() {
        
    // granting deployer the ADMIN role 
        _grantRole(ADMIN, msg.sender);
    }

    // checking if the user is a ADMIN or not 
    modifier onlyAdmin() {
        require(roles[ADMIN][msg.sender],"not authorised");
        _; 
    }
    
    //  internal that can be called inside
    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true ;

        emit GrantRole(_role, _account);
    }

    // only admin can grant role to other users
    function grantRole(bytes32 _role, address _account) external onlyAdmin {
        _grantRole(_role, _account);
    }
    
    function revokeRole(bytes32 _role, address _account) external onlyAdmin {
        roles[_role][_account] = false ;

        emit RevokeRole(_role, _account);
    }

}