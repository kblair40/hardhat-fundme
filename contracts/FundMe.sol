// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceConverter.sol";

// This can be more gas efficient than using 'require' in a modifier
error FundMe__NotOwner(); // newer feature for solidity.  Expect to see 'require' in most old code examples

/** @title A contract for crowd funding
 * @author Kevin Blair
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */

contract FundMe {
    using PriceConverter for uint256;

    // State Variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    // if variable is only set once, but in a different line than it was instantiated, we can use 'immutable' to save on gas
    address private immutable i_owner;
    // If we assign a variable in a contract only once, at compile time, we can make it a 'constant' to save on gas
    // txn cost with constant 21415 -> without constant 23515
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // uint256 public constant MINIMUM_USD = 50 * 10**18;
    AggregatorV3Interface private s_priceFeed;

    // modifier is a keyword that can be added to a function declaration to modify that function's functionality
    // functions that get the modifier do whatever is in the modifier first, then function body, then whetever is next in modifier
    modifier onlyOwner() {
        // require(msg.sender == owner, "Sender isnot owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        // immediately set owner to be the address the contract was deployed by/from
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happens if someone sends this contract ETH w/o calling the fund function?
    // receive and fallback will make sure the function gets called anyways.

    receive() external payable {
        // just call the fund function
        fund();
    }

    fallback() external payable {
        // same here, just call fund
        fund();
    }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        ); // if this fails, it will revert.  We can provide custom error msg as second arg
        s_funders.push(msg.sender); // msg.sender is the address sending the ether;
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // prevent anyone other than the owner from withdrawing
        // require(msg.sender == owner, "Sender is not owner!");

        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0); // (0) says init array with no length/objects in it
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // Add getters to clean up the api.  Users interacting with contract shouldn't need to know the s or i prefixes

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
