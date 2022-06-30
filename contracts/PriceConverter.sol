// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// yarn add --dev @chainlink/contracts
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        // NEED TO HAVE...
        // ABI -
        // ADDRESS - 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );

        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH in terms of USD

        // cast int256 to uint256, to match msg.value
        return uint256(price * 1e10); // 1**10 == 10000000000
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        // dividing by 1e18 ensures the result has 18 decimal places.  Make sure division happens last.
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;

        // EX. 3000_000000000000000000 = ETH / USD price
        // We send 1_000000000000000000 ETH to this contract, which equals $3000 (above)
        // To get price, multiply them together, and divide by 1e18 to get the 18 decimal places
    }
}
