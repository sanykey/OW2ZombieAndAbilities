#!mainFile "main.opy"

rule "Zombie points - elimination":
  @Event playerEarnedElimination
  @Team 1
  @Condition eventWasCriticalHit == false
  @Condition victim.getCurrentHero() == Hero.TORBJORN
  
  eventPlayer.money += MONEY_FOR_ZOMBIE_KILL * eventPlayer.H
  smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_ZOMBIE_KILL * eventPlayer.H, "Points")))
  teamScore += MONEY_FOR_ZOMBIE_KILL * eventPlayer.H


rule "Zombie points - critical hit":
  @Event playerEarnedElimination
  @Team 1
  @Condition eventWasCriticalHit == true
  @Condition victim.getCurrentHero() == Hero.TORBJORN
  
  eventPlayer.money += MONEY_FOR_ZOMBIE_CRITICAL * eventPlayer.H
  smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_ZOMBIE_CRITICAL * eventPlayer.H, "Points")))
  teamScore += MONEY_FOR_ZOMBIE_CRITICAL * eventPlayer.H


rule "Healing points":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.stateArr[stateI.HEALING_TRACKER] >= eventPlayer.stateArr[stateI.HEALING_TRACKER_THRESHOLD] 

  eventPlayer.stateArr[stateI.HEALING_RESULT] = ceil(eventPlayer.stateArr[stateI.HEALING_TRACKER] / HEAL_AMOUNT_FOR_MONEY) * MONEY_FOR_HEALING * eventPlayer.H
  eventPlayer.money += eventPlayer.stateArr[stateI.HEALING_RESULT]
  smallMessage(eventPlayer, "{0} {1}".format(eventPlayer.stateArr[stateI.HEALING_RESULT], "points for healing"))
  teamScore += eventPlayer.stateArr[stateI.HEALING_RESULT]
  eventPlayer.stateArr[stateI.HEALING_TRACKER] = 0

rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  
  # healing yourself gives less points
  eventPlayer.stateArr[stateI.HEALING_TRACKER] += eventHealing / 3 if healee == eventPlayer else  eventHealing
