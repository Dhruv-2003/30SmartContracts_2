// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// Swapping any 2 tokens with help of Uniswap Router V2

contract UniswapV2Swap {
    IUniswapV2Router private router;
    IERC20 private token1;
    IERC20 private token2;

    address private token1_address;
    address private token2_address;
    address private router_address;

    // Address for tryin to swap WETH to DAI
    // address private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address private DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // address private UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor(
        address UNISWAP_V2_ROUTER,
        address TOKEN1_address,
        address TOKEN2_address
    ) {
        token1_address = TOKEN1_address;
        token2_address = TOKEN2_address;
        router_address = UNISWAP_V2_ROUTER;
        router = IUniswapV2Router(UNISWAP_V2_ROUTER);
        token1 = IERC20(TOKEN1_address);
        token2 = IERC20(TOKEN2_address);
    }

    // Swap token1 Exact Amount to token2
    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amoutnOut)
    {
        /// send the tokens to this contract and then approve the router to use these tokens for the swap
        token1.transferFrom(msg.sender, address(this), amountIn);
        token1.approve(address(router), amountIn);

        /// creating the path of the swap , with the token Contract Addresses to swap
        address[] memory path;
        path = new address[](2);
        path[0] = token1_address;
        path[1] = token2_address;

        // swapExactTokensForTokens will swap the exact amount of in tokens
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // returns the amount
        // amounts[0] = token1 amount, amounts[1] = token2 amount
        return amounts[1];
    }

    // Swap token1 to token2 Exact Amount
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        /// sending the tokens to this contract and then approving the router to use the tokens
        token1.transferFrom(msg.sender, address(this), amountInMax);
        token1.approve(address(router), amountInMax);

        /// creating the path of the trade
        address[] memory path;
        path = new address[](2);
        path[0] = token1_address;
        path[1] = token2_address;

        /// swapTokensForExactTokens , swaps the tokens for the exact amount of output tokens
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

        return amounts[1];
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
