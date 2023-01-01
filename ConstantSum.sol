// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// TASK
/// Constant Sum Automated Market Maker
/// Follows reserver0 + reserve1 = k

contract CSAMM {
    // created token contract instance
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // tracks the internal balance of both the tokens
    uint256 public reserve0;
    uint256 public reserve1;

    // tracks the total share minted
    uint256 public totalSupply;
    // track individual share minted
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        // token intialisation
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // to mint some shares
    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    // to burn the shares
    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    // to update the reserve of both the tokens of this contract
    function _update(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    // swap 2 tokens which are in AMM
    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        // the tokens can just be token0  or token1
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );

        /// checking if the token is token0
        bool isToken0 = _tokenIn == address(token0);

        /// assigning the tokens on the basis of bool to be able to call some functions
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 resIn,
            uint256 resOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);

        /// transferring the tokens from sender to this contract
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        /*
        x + y = k
        x + dx + y + dy = k 

        dx = dy
         */

        // the token in will be the current balnce - the last reserve amount
        uint256 amountIn = tokenIn.balanceOf(address(this)) - resIn;

        // 0.3% fee
        // amountOut is 99.7% of the amountIn
        amountOut = (amountIn * 997) / 1000;

        // calculating the new reserve amount for each
        (uint256 res0, uint256 res1) = isToken0
            ? (resIn + amountIn, resOut - amountOut)
            : (resOut - amountOut, resIn + amountIn);

        /// updating the reserve balance
        _update(res0, res1);

        /// transferring the out token to the user
        tokenOut.transfer(msg.sender, amountOut);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1)
        external
        returns (uint256 shares)
    {
        /// transferring the tokens to the contract
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        /// fetching the balance of the tokens
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        /// the liquidity added for each will be current -  the last reported
        uint256 d0 = bal0 - reserve0;
        uint256 d1 = bal1 - reserve1;

        /*
        a = amount in
        L = total liquidity
        s = shares to mint
        T = total supply

        s should be proportional to increase from L to L + a
        (L + a) / L = (T + s) / T
        T = dx + dy 
        L = x + y
        s = a * T / L
        */

        /// calculating the shares to be minted
        if (totalSupply > 0) {
            shares = ((d0 + d1) * totalSupply) / (reserve0 + reserve1);
        } else {
            shares = d0 + d1;
        }

        /// minting the share for the user
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        ///  updating the reserve balance
        _update(bal0, bal1);
    }

    function removeLiquidity(uint256 _shares)
        external
        returns (uint256 d0, uint256 d1)
    {
        /*
        a = amount out
        L = total liquidity
        s = shares
        T = total supply

        a / L = s / T

        a = L * s / T
          = (reserve0 + reserve1) * s / T
        */
        d0 = (reserve0 * _shares) / totalSupply;
        d1 = (reserve1 * _shares) / totalSupply;

        _burn(msg.sender, _shares);
        _update(reserve0 - d0, reserve1 - d1);

        /// transferring the token0
        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }

        /// transferring the token1
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}
