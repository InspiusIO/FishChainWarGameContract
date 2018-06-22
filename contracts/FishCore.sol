pragma solidity ^0.4.22;

import './FishBase.sol';

//@title Base Contract for FishWarChain. Holds all functions related to the game's round.
//@author Inspius (https://www.inspius.com)
contract FishCore is FishBase {
	
	constructor() public {
	}

	//@dev end player game and transfer the reward, only owner .
	//all players need update the value before can endRound()
	function endPlayerGame(address playerAddress, uint256 playerValue)
		public
		onlyOwner
	{
		require(now > endTime);
		require(playerValue > 0);
		require(players[playerAddress].playerRound == round);

		Player storage player = players[playerAddress];

		//@dev check the player round and current playerValue
		if(player.playerRound == round && player.playerValue >= playerValue) {
			
			//@dev update the player value and send reward
			player.playerValue = playerValue;
			asyncSend(playerAddress, player.playerValue);

		}
	}

	//@dev end current round, give top players the bonus and start the new one, only owner can.
	function endRound(address playerTop1, address playerTop2, address playerTop3)
		public
		onlyOwner
	{
		require(now > endTime);
		require(players[playerTop1].playerRound == round);
		require(players[playerTop2].playerRound == round);
		require(players[playerTop3].playerRound == round);
		
		//@dev end sure the top players are ended game
		if(players[playerTop1].playerValue > players[playerTop2].playerValue && players[playerTop2].playerValue > players[playerTop3].playerValue) {

			//@dev cut the top 1 player reward from current leader bonus price
			uint256 bonusForPlayerTop1 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 50), 100);
			asyncSend(playerTop1, bonusForPlayerTop1);

			//@dev cut the top 2 player reward from current leader bonus price
			uint256 bonusForPlayerTop2 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 30), 100);
			asyncSend(playerTop2, bonusForPlayerTop2);

			//@dev cut the top 3 player reward from current leader bonus price
			uint256 bonusForPlayerTop3 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 20), 100);
			asyncSend(playerTop3, bonusForPlayerTop3);
			
			//@dev reset current leader bonus price
			currentLeaderBonusPrice = 0;
			
			//@dev go for new round
			startNewRound();
		}
	}

	//@dev start a new round, only owner can.
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
		emit eventCreatePlayer(msg.sender, player.playerValue);
    }
}
