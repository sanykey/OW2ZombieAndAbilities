#!mainFile "main.opy"

rule "[Echo - Freeze Beam]":
  @Event playerDealtDamage
  @Team 1
  @Hero echo
  @Condition eventAbility == Button.ABILITY_2
  @Condition attacker != victim
  
  getPlayersInRadius(victim, 5, Team.2).setStatusEffect(eventPlayer, Status.FROZEN, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, victim, 5)
  wait(2.1)

rule "[Buff To Cassidy Ultimate]":
  @Event eachPlayer
  @Team 1
  @Hero cassidy
  @Condition eventPlayer.isUsingUltimate() == true
  
  wait(0.02)
  eventPlayer.getPlayersInViewAngle(Team.2, 90).setStatusEffect(null, Status.ROOTED, 2.5)

rule "Mei frosty jet pack":
  @Event eachPlayer
  @Condition eventPlayer.getCurrentHero() == Hero.MEI
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.isInAir() == true
  
  eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), -2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
  wait(0.1)
  if RULE_CONDITION:
      goto RULE_START

