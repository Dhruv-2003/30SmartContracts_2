// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// this contract will just manage all the roles
/// we can inherit in the main contract after deploying to control the access and assign particular roles
contract AccessControl {
    /// mapping from role > account > bool
    mapping(bytes32 => mapping(address => bool)) public roles;

    /// Events that are emitted when a role is granted or revoked
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    /// we tagged them as constant we don't want anyone to change the role
    /// String is converted to the keccak256 hash after encoding
    bytes32 private constant ADMIN = keccak256(abi.encodePacked(("ADMIN")));
    bytes32 private constant USER = keccak256(abi.encodePacked(("USER")));
    bytes32 private constant MODERATOR =
        keccak256(abi.encodePacked(("MODERATOR")));

    // user need to pass the bytes form of the role
    constructor() {
        // granting deployer the ADMIN role
        _grantRole(ADMIN, msg.sender);
    }

    // checking if the user is a ADMIN or not
    modifier onlyAdmin() {
        require(roles[ADMIN][msg.sender], "not authorised");
        _;
    }

    // modifer for each kind of role to restrict access to certain functions
    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorised");
        _;
    }

    //  internal that can be called inside
    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;

        emit GrantRole(_role, _account);
    }

    // only admin can grant role to other users
    function grantRole(bytes32 _role, address _account) external onlyAdmin {
        _grantRole(_role, _account);
    }

    /// revoke the role given to the address
    function revokeRole(bytes32 _role, address _account) external onlyAdmin {
        roles[_role][_account] = false;

        emit RevokeRole(_role, _account);
    }
}
