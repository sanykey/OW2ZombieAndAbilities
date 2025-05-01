#!mainFile "main.opy"

rule "Zombie points - elimination":
  @Event playerEarnedElimination
  @Team 1
  @Condition victim.getCurrentHero() == Hero.TORBJORN
  
  # Money for kill. Critical hit, melee or hacked victim give more money
  eventPlayer.state[SI.MONEY_RECEIVED] = (
    (MONEY_FOR_ZOMBIE_CRITICAL if eventWasCriticalHit == true or eventAbility == Button.MELEE else MONEY_FOR_ZOMBIE_KILL) +
    (30 if victim.state[SI.HACKED] == true else 0)
  ) * eventPlayer.H

  smallMessage(eventPlayer, "{0} points".format(eventPlayer.state[SI.MONEY_RECEIVED]))
  eventPlayer.money += eventPlayer.state[SI.MONEY_RECEIVED]
  teamScore += eventPlayer.state[SI.MONEY_RECEIVED]

  # Money for the rest of the players who weren't involved in this kill.
  eventPlayer.temp1 = [player for player in getLivingPlayers(Team.1) if victim.damageAssitsToSlot[player.getSlot()] < getTotalTimeElapsed() ]

  for eventPlayer.temp2 in range(len(eventPlayer.temp1)):
    smallMessage(eventPlayer.temp1[eventPlayer.temp2], "{0} points".format((60 if victim.state[SI.HACKED] == true else 50) * eventPlayer.H))
    eventPlayer.temp1[eventPlayer.temp2].money += (60 if victim.state[SI.HACKED] == true else 50) * eventPlayer.H

rule "Healing points":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.HEALING_TRACKER] >= eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] 

  eventPlayer.state[SI.HEALING_RESULT] = floor(eventPlayer.state[SI.HEALING_TRACKER] / HEAL_AMOUNT_FOR_MONEY) * MONEY_FOR_HEALING * eventPlayer.H
  eventPlayer.money += eventPlayer.state[SI.HEALING_RESULT]
  smallMessage(eventPlayer, "{0} {1}".format(eventPlayer.state[SI.HEALING_RESULT], "points for healing"))
  teamScore += eventPlayer.state[SI.HEALING_RESULT]
  eventPlayer.state[SI.HEALING_TRACKER] = 0

rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  
  # healing yourself gives less points
  eventPlayer.state[SI.HEALING_TRACKER] += eventHealing / 3 if healee == eventPlayer else eventHealing
