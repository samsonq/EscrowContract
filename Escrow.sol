pragma solidity ^0.5;

contract Escrow {

    enum Status {PENDING_PAYMENT, PENDING_DELIVERY, COMPLETED, REFUNDED}
    Status public currentStatus;

    address payable public buyer;
    address payable public seller;
    address public controller;

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
        require(msg.sender == buyer, "Only Buyer");
        _;
    }

    modifier status(Status _status) {
        require(currentStatus == _status, "Wrong Status");
        _;
    }

    function pay() public payable onlyBuyer status(Status.PENDING_PAYMENT) {
        currentStatus = Status.PENDING_DELIVERY;
    }

    function confirmReceipt() public onlyBuyer status(Status.PENDING_DELIVERY) {
        currentStatus = Status.COMPLETED;
        seller.transfer(address(this).balance);
    }

    function refund() public onlySeller status(Status.PENDING_DELIVERY) {
        currentStatus = Status.REFUNDED;
        buyer.transfer(address(this).balance);
    }
}
