pragma solidity ^0.4.11;
"""
**** Currently UNTESTED ****

# Escrow Contract #
Involves three 'actors' -- 'sender', 'recipient', 'arbitrator'
Holds Ether from 'sender' to be transferred to 'recipient'.
Ether in contract is transferred to 'recipient' when two of the three 'actors' `confirm`.
Contract can be `void`ed by 'sender' after `blocksUntilExpire` blocks have passed since contract creation.
Ether is transferred to 'sender' upon successful `void`.

"""

contract Escrow {
    /*
        Escrow is initialized with references to three parties (addresses)
        as well as the number of blocks until expiration.
        The amount to be held in escrow can be sent upon initialization or in any transaction after.
    */
    function Escrow(address _sender, address _recipient, address _arbitrator, uint blocksUntilExpire) {
        actors.push(_sender);
        actors.push(_recipient);
        actors.push(_arbitrator);
        expirationBlock = now + blocksUntilExpire;
    }

    /*
       Any of the initially specified actors can call confirm().
       Once there are enough confirmations (2) confirm releases funds to recipient.
    */
    function confirm() only_actor {
        confirmations[msg.sender] = true;
        if (isConfirmed()) {
            assert(recipient().call.value(this.balance)());
        }
    }

    /*
        Sender can void escrow agreement after expiration.
        Voiding sends all funds held in contract back to the sender.
    */
    function void() only_sender {
        assert(now > expirationBlock);
        assert(sender().call.value(this.balance)());
    }

    /*
       Sender of funds in contract.
       Only party that can void and return funds
    */
    function sender() constant returns (address) {
        return actors[0];
    }

    /*
       Recipient of funds in contract.
       Receives funds after two confirms from distinct valid parties
    */
    function recipient() constant returns (address) {
        return actors[1];
    }

    /*
       Count number of confirms
       returns true if two or more
    */
    function isConfirmed() constant returns (bool) {
        uint confCount = 0;
        for (uint i = 0; i < actors.length; i++) {
            if (confirmations[actors[0]]) {
                confCount++;
            }
        }
        return (confCount >= 2);
    }

    /*
       returns true if address is either the sender, recipient, or artibtrator
    */
    function isActor(address addr) constant returns (bool) {
        for (uint i = 0; i < actors.length; i++) {
            if (actors[i] == addr) return true;
        }
        return false;
    }

    modifier only_actor { require(isActor(msg.sender)); _; }
    modifier only_sender { require(sender() == msg.sender); _; }

    address[] public actors;
    mapping (address => bool) public confirmations;
    uint public expirationBlock;
}