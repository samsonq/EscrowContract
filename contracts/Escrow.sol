pragma solidity ^0.5;

import "./common/SafeMath.sol";
import "./common/Destructible.sol";
import "./common/Ownable.sol";

contract Escrow is Ownable, Destructible {

    enum Status {PENDING_PAYMENT, PENDING_DELIVERY, COMPLETED, REFUNDED}
    Status public currentStatus;

    event Paid();
    event Refunded();

    address payable public buyer;
    address payable public seller;
    address public controller;

    using SafeMath for uint256;

    constructor(address payable _buyer, address payable _seller, address _controller) public {
        buyer = _buyer;
        seller = _seller;
        controller = _controller;
    }

    modifier onlySeller() {
        require(msg.sender == seller || msg.sender == controller, "Only Owner");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer || msg.sender == controller, "Only Buyer");
        _;
    }

    modifier status(Status _status) {
        require(currentStatus == _status, "Wrong Status");
        _;
    }

    function getCustomer() public view returns(uint256) {
        return buyer.balance;
    }

    function getSeller() public view returns(uint256) {
        return seller.balance;
    }

    function pay() public payable onlyBuyer status(Status.PENDING_PAYMENT) {
        require(msg.sender.value == 0.01 ether, "Not Enough Funds!");
        currentStatus = Status.PENDING_DELIVERY;
        emit Paid();
    }

    function confirmReceipt() public onlyBuyer status(Status.PENDING_DELIVERY) {
        currentStatus = Status.COMPLETED;
        seller.transfer(address(this).balance);
    }

    function refund() public onlySeller status(Status.PENDING_DELIVERY) {
        currentStatus = Status.REFUNDED;
        buyer.transfer(address(this).balance);
        emit Refunded();
    }
}
