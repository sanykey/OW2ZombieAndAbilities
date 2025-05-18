#!mainFile "main.opy"

# rule "Zombie points - elimination":
#   @Event playerEarnedElimination
#   @Team 1
  
#   # Money for kill. Critical hit, melee or hacked victim give more money
#   eventPlayer.state[SI.MONEY_RECEIVED] = (
#     (MONEY_FOR_ZOMBIE_CRITICAL if eventWasCriticalHit == true or eventAbility == Button.MELEE else MONEY_FOR_ZOMBIE_KILL) +
#     (MONEY_FOR_KILL_HACKED if victim.state[SI.HACKED] == true else 0)
#   ) * eventPlayer.H

#   smallMessage(eventPlayer, "{0} points".format(eventPlayer.state[SI.MONEY_RECEIVED]))
#   eventPlayer.money += eventPlayer.state[SI.MONEY_RECEIVED]
#   teamScore += eventPlayer.state[SI.MONEY_RECEIVED]

#   # Money for the rest of the players who weren't involved in this kill.
#   eventPlayer.temp1 = [player for player in getLivingPlayers(Team.1) if victim.damageAssitsToSlot[player.getSlot()] < getTotalTimeElapsed() ]

#   for eventPlayer.temp2 in range(len(eventPlayer.temp1)):
#     # todo: MONEY_FOR_KILL_HACKED_TEAM
#     smallMessage(eventPlayer.temp1[eventPlayer.temp2], "{0} points".format((60 if victim.state[SI.HACKED] == true else 50) * eventPlayer.H))
#     eventPlayer.temp1[eventPlayer.temp2].money += (60 if victim.state[SI.HACKED] == true else 50) * eventPlayer.H


