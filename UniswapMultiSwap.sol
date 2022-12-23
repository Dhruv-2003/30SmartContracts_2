// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// Checked and tested

/// Swapping Multiple tokens with help of Uniswap Router V2
/// We just add the token in the path to be able to swap multiple times in the pre defined order

contract UniswapV2MultiSwap {
    IUniswapV2Router private router;
    IERC20 private token1;
    IERC20 private token2;

    address private token1_address;
    address private token2_address;
    address private token3_address;
    address private router_address;

    // Address for tryin to swap DAI -> WETH -> USDC
    // address private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address private DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    // address private UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor(
        address UNISWAP_V2_ROUTER,
        address TOKEN1_address,
        address TOKEN2_address,
        address TOKEN3_address
    ) {
        token1_address = TOKEN1_address;
        token2_address = TOKEN2_address;
        token3_address = TOKEN3_address;
        router_address = UNISWAP_V2_ROUTER;
        router = IUniswapV2Router(UNISWAP_V2_ROUTER);
        token1 = IERC20(TOKEN1_address);
        token2 = IERC20(TOKEN2_address);
    }

    // Swap token1 Exact Amount In -> token2 -> token3
    function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amoutnOut)
    {
        /// send the in token and approve the router to spend it
        token1.transferFrom(msg.sender, address(this), amountIn);
        token1.approve(address(router), amountIn);

        /// define the tokens to be swapped in path in the swapping order you want to swap
        address[] memory path;
        path = new address[](3);
        path[0] = token1_address;
        path[1] = token2_address;
        path[2] = token3_address;

        /// Intiate the swap instantly , with path and amount
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // amounts[0] = token1 amount
        // amounts[1] = token2 amount
        // amounts[2] = token3 amount
        return amounts[2];
    }

    // Swap token1 -> token2 -> token3 Exact amount Out
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        /// send the in token and approve the router to spend it
        token1.transferFrom(msg.sender, address(this), amountInMax);
        token1.approve(address(router), amountInMax);

        /// define the tokens to be swapped in path in the swapping order
        address[] memory path;
        path = new address[](3);
        path[0] = token1_address;
        path[1] = token2_address;
        path[2] = token3_address;

        /// Intiate the swap instantly , with path and amount
        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        // Refund token1 to msg.sender
        if (amounts[0] < amountInMax) {
            token1.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[2];
    }
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
