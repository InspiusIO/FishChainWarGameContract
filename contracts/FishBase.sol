pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/payment/PullPayment.sol";

/// @title Base Contract for FishWarChain. Holds all common structs, events and base variables.
/// @author Inspius (https://www.inspius.com)
contract FishBase is Ownable, PullPayment {
	
	constructor () public {}

	//@dev this game's round.
	uint256 round = 0;

	//@dev this round's end time.
	uint256 public endTime;
	
	//@dev a round time. 15 minutes.
	uint256 public roundTime = 15 * 60;

	//@dev Base price to join this game.
	uint256 basePrice = 0.01 ether;

	//@dev 20% of total prev game size will be next Leader Bonus, start at 0.
	uint256 leaderBonusPrice = 0 ether;

	//@dev List of all players in this round.
    Player[] public players;
	
	//@dev When a Player is created, player can start joining this game's round
    //until the round is ended. The player's value will start at 0.01 ether 
	//and increase when a player killed a another player.
	struct Player {
		
		//@dev the player's address
        address playerAddress;
		
		//@dev the player's round
        uint256 round;
		
		//@dev the player's value. It should start at 0.01
        uint256 value;
    }
}
