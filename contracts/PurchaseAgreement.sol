// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.11;

contract PurchaseAgreement {

    uint public price;
    address payable public merchant;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive }
    State public state;

    constructor() payable {
        merchant =  payable(msg.sender);
        price = msg.price / 2;
    }

    error InvalidState();

    error OnlyBuyer();

    error OnlyMerchant();

    modifier inState(State state_) {
        if (state != state_){
            revert InvalidState();
        }
        _;  
    }

    modifier onlyBuyer() {
        if (msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }
    modifier onlyMerchant() {
        if (msg.sender != merchant){
            revert OnlyMerchant();
        }
        _;
    }

    function confirmPurchase() external inState(State.Created) payable {
        require(msg.price == (2 * price), "Send 2x the purchase amount");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmReceieved() external onlyBuyer inState(State.Locked) {

        state = State.Release;
        buyer.transfer(price);

    }

    function paySeller() external onlyMerchant inState(State.Release) {

        state = State.Inactive;
        merchant.transfer(3 * price);
    }

    function abort() external onlyMerchant inState(State.Created) {
        state = State.Inactive;
        merchant.transfer(address(this).balance);
    }
}