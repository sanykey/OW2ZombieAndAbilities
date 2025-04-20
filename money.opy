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
  @Condition eventPlayer.healingTracker >= HEAL_AMOUNT_FOR_MONEY

  while eventPlayer.healingTracker > HEAL_AMOUNT_FOR_MONEY:
    eventPlayer.healingTracker -= HEAL_AMOUNT_FOR_MONEY
    eventPlayer.money += MONEY_FOR_SELF_HEALING * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_SELF_HEALING * eventPlayer.H, "Points")))
    teamScore += MONEY_FOR_SELF_HEALING * eventPlayer.H


rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  @Condition healee != eventPlayer
  
  eventPlayer.healingTracker += eventHealing


rule "self healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  @Condition healee == eventPlayer
  
  eventPlayer.healingTracker += eventHealing / 2
  