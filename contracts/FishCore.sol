pragma solidity ^0.4.22;

import './FishBase.sol';

//@title Base Contract for FishWarChain. Holds all functions related to the game's round.
//@author Inspius (https://www.inspius.com)
contract FishCore is FishBase {
	
	constructor() public {
	}

	//@dev end round, give top players the bonus and start the new game, only onwer can.
	function endRound(uint256 clientRound, address[] clientPlayers, uint256[] values)
		public
		onlyOwner
	{
		require(now > endTime);
		require(clientRound == round);

		//@dev update the player result from client into the contract
		uint256 index = 0;
        while (index < clientPlayers.length) {
            if(players[clientPlayers[index]].playerRound == round) {
				Player storage player = players[clientPlayers[index]];
				//@dev update the player value and send reward
				player.playerValue = values[index];
				asyncSend(clientPlayers[index], values[index]);
				lastRoundPlayers[clientPlayers[index]] = SafeMath.add(lastRoundPlayers[clientPlayers[index]],values[index]);
			}
            index += 1;
        }
		//@dev give the top players reward from leader bonus
		if(index > 0 && players[clientPlayers[0]].playerRound == round) {
			//@dev cut the top 1 player reward from current leader bonus price
			uint256 bonusForPlayerTop1 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 50), 100);
			asyncSend(clientPlayers[0], bonusForPlayerTop1);
			lastRoundPlayers[clientPlayers[0]] = SafeMath.add(lastRoundPlayers[clientPlayers[0]], bonusForPlayerTop1);
			currentLeaderBonusPrice = SafeMath.sub(currentLeaderBonusPrice, bonusForPlayerTop1);
		}
		if(index > 1 && players[clientPlayers[1]].playerRound == round) {
			//@dev cut the top 2 player reward from current leader bonus price
			uint256 bonusForPlayerTop2 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 30), 100);
			asyncSend(clientPlayers[1], bonusForPlayerTop2);
			lastRoundPlayers[clientPlayers[1]] = SafeMath.add(lastRoundPlayers[clientPlayers[1]], bonusForPlayerTop2);
			currentLeaderBonusPrice = SafeMath.sub(currentLeaderBonusPrice, bonusForPlayerTop2);
		}
		if(index > 2 && players[clientPlayers[2]].playerRound == round) {
			//@dev cut the top 3 player reward from current leader bonus price
			uint256 bonusForPlayerTop3 = SafeMath.div(SafeMath.mul(currentLeaderBonusPrice, 20), 100);
			asyncSend(clientPlayers[2], bonusForPlayerTop3);
			lastRoundPlayers[clientPlayers[2]] = SafeMath.add(lastRoundPlayers[clientPlayers[2]], bonusForPlayerTop3);
			currentLeaderBonusPrice = 0;
		}

		//@dev go for new round
		startNewRound();
		
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
		
		//@dev move the current leader bonus to next round bonus, in case number of players < 3
		if(currentLeaderBonusPrice > 0) {
			nextLeaderBonusPrice = SafeMath.add(nextLeaderBonusPrice, currentLeaderBonusPrice);
		}

		//@dev use next leader bonus price as current leader bonus price
		currentLeaderBonusPrice = nextLeaderBonusPrice;
		
		//@dev reset next leader bonus price to zero
		nextLeaderBonusPrice = 0;

		//@dev use leader bonus price as start total round price
		totalRoundPrice = currentLeaderBonusPrice;

		//emit started new round event
		emit eventStartNewRound(round, endTime);
	}

	//@dev buy a fish to join the game
	function buy()
        public
        payable
    {
		//@dev owner can't play the game.
		require(msg.sender != owner);

        createPlayer(msg.value);
    }
	
	//@dev create player to join this round.
    function createPlayer(uint256 incomingEthereum)
        internal
    {
		require(incomingEthereum == basePrice);
		require(now <= endTime);

		//@dev cut the dev fee
		uint256 devFee = getDevFee(incomingEthereum);
		asyncSend(owner, devFee);

		//@dev cut the leader bonus fee to next round
		uint256 leaderBonusFee = getLeaderBonusFee(incomingEthereum);		
		addNextLeaderBonus(leaderBonusFee);
		
		Player storage player = players[msg.sender];
		
		//@dev reset player value and round for this round
		if(player.playerRound != round) {
			player.playerValue = 0;
			player.playerRound = round;
		}

		uint256 valueAfterFee = SafeMath.sub(msg.value, SafeMath.add(devFee, leaderBonusFee));
		
		//@dev add the player value
		player.playerValue = SafeMath.add(player.playerValue, valueAfterFee);
		
		//@dev add the value to this round
		addTotalRoundPrice( valueAfterFee );
		
		//@dev emit created player event
		emit eventCreatePlayer(msg.sender, player.playerRound, player.playerValue);
    }
	
	//@dev fallback function to handle ethereum that was send straight to the contract
	function()
        payable
        public
    {
        revert(); 
    }
}
