// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CPAMM {
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
    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
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

        require(_amountIn > 0, "amount in = 0");

        /// checking if the token is token0
        bool isToken0 = _tokenIn == address(token0);

        /// assigning the tokens on the basis of bool to be able to call some functions
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);

        /// transferring the tokens from sender to this contract
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // 0.3% fee
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        /*
        ydx / (x + dx) = dy
        */
        // y = reserveOut , dy = amountOut
        // x = reserveIn , dx = amountInWithFee
        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);

        /// tokensOut transferred to the sender
        tokenOut.transfer(msg.sender, amountOut);

        // swap complete

        // updating the reserve of the contract
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1)
        external
        returns (uint256 shares)
    {
        /// transferring the tokens to the contract first
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        /*
        x / y = (x + dx) / (y + dy)
        x * dy = y * dx
        x / y = dx / dy
        */
        if (reserve0 > 0 || reserve1 > 0) {
            require(
                reserve0 * _amount1 == reserve1 * _amount0,
                "x / y != dx / dy"
            );
        }

        /*
        How much shares to mint?

        f(x, y) = value of liquidity  = sqrt(xy)

        L0 = f(x, y)
        L1 = f(x + dx, y + dy)
        T = total shares
        s = shares to mint

        Total shares should increase proportional to increase in liquidity
        L1 / L0 = (T + s) / T
        (L1 - L0)*T / L0 = s 


        on solving ,we get the result as below
        (L1 - L0) / L0 = dx / x = dy / y

        s = dx * T / x = dy * T / y
        */

        if (totalSupply == 0) {
            /// then S = T = sqrt(XY)
            shares = _sqrt(_amount0 * _amount1);
        } else {
            /// whichever value is minimum will be the amount of shares of (dx * T / x ) or (dy * T / y)
            shares = _min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }

        require(shares > 0, "shares = 0");

        /// mint the shares for the user
        _mint(msg.sender, shares);

        /// update the reserve of the tokens again
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function removeLiquidity(uint256 _shares)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        /*
        dx, dy = amount of liquidity to remove
        dx = s / T * x
        dy = s / T * y
        

        Calculation :

        where
        v = f(dx, dy) = sqrt(dxdy)
        L = total liquidity = sqrt(xy)
        s = shares
        T = total supply

        v = s / T * L
        Likewise
        dy = s / T * y
        dx = s / T * x

        */

        // fetching the current balance from the contract
        // bal0 >= reserve0
        // bal1 >= reserve1
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        /// calculating the amounts of both the tokens
        amount0 = (_shares * bal0) / totalSupply;
        amount1 = (_shares * bal1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        /// burn the shares and update the reserve
        _burn(msg.sender, _shares);
        _update(bal0 - amount0, bal1 - amount1);

        /// now transferring the tokens back to the user
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }

    /// function to find the square root of a value
    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /// function to find the minimum of both the values
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
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
