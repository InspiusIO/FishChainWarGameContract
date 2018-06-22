pragma solidity ^0.4.22;

import './FishBase.sol';

//@title Base Contract for FishWarChain. Holds all functions related to the game's round.
//@author Inspius (https://www.inspius.com)
contract FishCore is FishBase {
	
	constructor() public {
	}

	//@dev start a new round, only onwer can.
	function startNewRound()
		public
		onlyOwner
	{
		require(now > endTime);
		
		//@dev update end time for this new round
		endTime = SafeMath.add(now, roundTime);

		//@dev update round to new round
        round = SafeMath.add(round, 1);
		
		//@dev use next leader bonus price as current leader bonus price
		currentLeaderBonusPrice = nextLeaderBonusPrice;
		
		//@dev reset next leader bonus price to zero
		nextLeaderBonusPrice = 0;

		//@dev use leader bonus price as start total round price
		totalRoundPrice = currentLeaderBonusPrice;

		//emit started new round event
		emit eventStartNewRound(round, endTime);
	}

	//@dev end current round and start the new one, only onwer can.
	function endRound()
		public
		onlyOwner
	{
		require(now > endTime);
		
		startNewRound();
	}
	
	//@dev create player to join this round.
    //@return player id in the contract.
    function createPlayer()
        public
        payable
    {
		require(msg.value == basePrice);
		require(now <= endTime);

		//@dev cut the dev fee
		uint256 devFee = getDevFee(msg.value);
		asyncSend(owner, devFee);

		//@dev cut the leader bonus fee to next round
		uint256 leaderBonusFee = getLeaderBonusFee(msg.value);		
		addNextLeaderBonus(leaderBonusFee);
		
		Player storage player = players[msg.sender];
		
		uint256 valueAfterFee = SafeMath.sub(msg.value, SafeMath.add(devFee, leaderBonusFee));
		
		//@dev reset player value for this round
		if(player.playerRound != round) {
			player.playerValue = 0;
		}
		
		//@dev add the player value
		player.playerValue = SafeMath.add(player.playerValue, valueAfterFee);
		
		//@dev add the value to this round
		addTotalRoundPrice(player.playerValue);
		
		//@dev emit created player event
		emit eventCreatePlayer(msg.sender);
    }
}
