pragma solidity ^0.4.22;

import './FishBase.sol';

//@title Base Contract for FishWarChain. Holds all functions related to the game's round.
//@author Inspius (https://www.inspius.com)
contract FishCore is FishBase {
	
	constructor() public {
	}
	
	//@dev create player to join this round.
    //@return player id in the contract.
    function createPlayer()
        public
        payable
    {
		require(msg.value == basePrice);
		
		//@dev cut the dev fee
		uint256 devFee = getDevFee(msg.value);
		asyncSend(owner, devFee);

		//@dev cut the leader bonus fee to next round
		uint256 leaderBonusFee = getLeaderBonusFee(msg.value);		
		addLeaderBonus(leaderBonusFee);
		
		Player storage player = players[msg.sender];
		
		uint256 valueAfterFee = SafeMath.sub(msg.value, SafeMath.add(devFee, leaderBonusFee));
		
		//@dev reset player value for this round
		if(player.playerRound != round) {
			player.playerValue = 0;
		}
		
		//@dev add the player value
		player.playerValue = SafeMath.add(player.playerValue, valueAfterFee);
		
		addTotalRoundPrice(player.playerValue);
    }
}
