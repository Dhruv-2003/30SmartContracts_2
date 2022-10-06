// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IlendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);
}

contract AAVEPool {
    address public owner;

    address public aavePool;
    IlendingPool public _aavePool;

    mapping(address => bool) public accountList;

    constructor(address _aavePoolAddress) {
        aavePool = _aavePoolAddress;
        _aavePool = IlendingPool(_aavePoolAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyAuthorized() {
        require(
            !accountList[msg.sender] && msg.sender != owner,
            "Not authorized"
        );
        _;
    }

    /// @dev - add account to whitelist
    function allowAccount(address _account) external onlyOwner {
        accountList[_account] = true;
    }

    /// @dev - remove account to whitelist
    function removeAccount(address _account) external onlyOwner {
        accountList[_account] = false;
    }

    /// @dev - change the owner
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    /// @dev - To deposit some funds into the AAVE pool , to earn some interest
    /// @param _token -  ERC20 token address to be borrowed
    /// @param _amount - Amount of tokens
    function depositFunds(address _token, uint256 _amount)
        external
        onlyAuthorized
    {
        _aavePool.deposit(_token, _amount, msg.sender, 0);
    }

    /// @dev - To withdraw the funds deposited into the AAVE Pool
    /// @param _token -  ERC20 token address to be borrowed
    /// @param _amount - Amount of tokens
    function withdrawFunds(address _token, uint256 _amount)
        external
        onlyAuthorized
    {
        _aavePool.withdraw(_token, _amount, msg.sender);
    }

    /// @dev - To borrow some funds against the collateral deposited
    /// @param _token -  ERC20 token address to be borrowed
    /// @param _amount - Amount of tokens
    /// @param interestRateType - the type of borrow debt. Stable: 1, Variable: 2
    function borrowFunds(
        address _token,
        uint256 _amount,
        uint256 interestRateType
    ) external onlyAuthorized {
        _aavePool.borrow(_token, _amount, interestRateType, 0, msg.sender);
    }

    /// @dev - Repay the funds which were borrowed
    /// @param _token -  ERC20 token address to be borrowed
    /// @param _amount - Amount of tokens
    /// @param interestRateType - the type of borrow debt. Stable: 1, Variable: 2
    function repayFunds(
        address _token,
        uint256 _amount,
        uint256 interestRateType
    ) external onlyAuthorized {
        _aavePool.repay(_token, _amount, interestRateType, msg.sender);
    }
}
