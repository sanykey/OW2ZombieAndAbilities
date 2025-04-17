#!mainFile "main.opy"

rule "[Zombie Points - Elimination]":
  @Event playerEarnedElimination
  @Team 1
  @Condition eventWasCriticalHit == false
  @Condition victim.getCurrentHero() == Hero.TORBJORN
  
  eventPlayer.money += 200 * eventPlayer.H
  smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(200 * eventPlayer.H, l"Points")))
  eventPlayer.startHealingOverTime(eventPlayer, 5, 30)
  R += 200 * eventPlayer.H


rule "[Zombie Points - Critical Hit]":
  @Event playerEarnedElimination
  @Team 1
  @Condition eventWasCriticalHit == true
  @Condition victim.getCurrentHero() == Hero.TORBJORN
  
  eventPlayer.money += 275 * eventPlayer.H
  smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(275 * eventPlayer.H, l"Points")))
  eventPlayer.startHealingOverTime(eventPlayer, 5, 30)
  R += 275 * eventPlayer.H

rule "[Healing Points]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.healing_tracker >= 120
  
  eventPlayer.money += 75 * eventPlayer.H
  eventPlayer.healing_tracker = 0
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(75 * eventPlayer.H, "Points")))
  R += 75 * eventPlayer.H


rule "[Healing Amount Tracker]":
  @Event playerDealtHealing
  @Team 1
  @Condition healee == eventPlayer == false
  
  eventPlayer.healing_tracker += eventHealing


rule "[Self Healing Amount Tracker]":
  @Event playerDealtHealing
  @Team 1
  @Condition healee == eventPlayer == true
  
  eventPlayer.healing_tracker += eventHealing / 2
  