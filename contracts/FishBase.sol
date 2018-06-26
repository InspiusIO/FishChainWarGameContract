pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/payment/PullPayment.sol";

/// @title Base Contract for FishWarChain. Holds all common structs, events and base variables.
/// @author Inspius (https://www.inspius.com)
contract FishBase is Ownable, PullPayment {
	
	constructor() public {}

	//@dev this game's round.
	uint256 public round = 0;

	//@dev this round's end time.
	uint256 public endTime = 0;
	
	//@dev a round time. 15 minutes.
	uint256 roundTime = 15 * 60;
	
	//@dev total round price
	uint256 public totalRoundPrice = 0 ether;

	//@dev Base price to join this game.
	uint256 public basePrice = 0.01 ether;
	
	//@dev current leader bonus price. start at 0 ether
	uint256 public currentLeaderBonusPrice = 0 ether;

	//@dev 20% of total prev game size will be next Leader Bonus, start at 0 ether.
	uint256 nextLeaderBonusPrice = 0 ether;

	//@dev List of all players in this round.
    mapping(address => Player) internal players;

	//@dev eventStartNewRound event is emitted whenever a new round is started.
    event eventStartNewRound(
        uint256 nextRound,
        uint256 nextEndTime
    );

	//@dev eventCreatePlayer event is emitted whenever a playe is created.
    event eventCreatePlayer(
        address playerAddress,
		uint256 playerRound,
		uint256 playerValue
    );
	
	//@dev When a Player is created, player can start joining this game's round
    //until the round is ended. The player's value will start at 0.01 ether 
	//and increase when a player killed a another player.
	struct Player {
		
		//@dev the player's round
        uint256 playerRound;
		
		//@dev the player's value. It should start at 0.01 ether
        uint256 playerValue;

    }
	
	//@dev helper to get the dev fee of amount, current is 10%
	function getDevFee(uint256 amount) internal pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, 10), 100);
    }
	
	//@dev helper to get the leader bonus fee of amount, current is 20%
	function getLeaderBonusFee(uint256 amount) internal pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, 20), 100);
    }

	//@dev helper to add amount to leader bonus
	function addNextLeaderBonus(uint256 amount) internal returns(uint256) {
		nextLeaderBonusPrice = SafeMath.add(nextLeaderBonusPrice, amount);
        return nextLeaderBonusPrice;
    }

	//@dev helper to add amount to total round price
	function addTotalRoundPrice(uint256 amount) internal returns(uint256) {
		totalRoundPrice = SafeMath.add(totalRoundPrice, amount);
        return totalRoundPrice;
    }
}
