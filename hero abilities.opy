#!mainFile "main.opy"

rule "[Sigma] Vacuum Succ":
  @Event eachPlayer
  @Team 1
  @Hero sigma
  @Condition eventPlayer.isUsingAbility1() == true
  
  eventPlayer.getPlayersInViewAngle(Team.2, 45).setStatusEffect(null, Status.KNOCKED_DOWN, 2.5)
  eventPlayer.startHealingOverTime(eventPlayer, 3, 100)
  wait(3)
  eventPlayer.stopAllHealingOverTime()

rule "[Symmetra] Photon Barrier+":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.isUsingUltimate() == true
  
  smallMessage(getAllPlayers(), "[Photon Barrier+] 50% Damage Reduction (12s)")
  getPlayers(Team.1).setDamageReceived(50)
  wait(12)
  getPlayers(Team.1).setDamageReceived(100)

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

rule "[Sombra] Hack+":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
    
    eventPlayer.setStatusEffect(null, Status.STUNNED, 2.5)
    smallMessage(getPlayersOnHero(Hero.SOMBRA, Team.1), "Hack+ Activated: Stun")

rule "[Mercy Immune During Revive]":
  @Event eachPlayer
  @Team 1
  @Hero mercy
  @Condition eventPlayer.isUsingAbility2() == true
  
  eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 4)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.YELLOW, eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer, 5)
  smallMessage(eventPlayer, "Temporarily Immune (4s) | Heroes Never Die!")
  wait(1.7)
  if not RULE_CONDITION:
      return
  getPlayersInRadius(eventPlayer, 10, Team.2).setStatusEffect(null, Status.STUNNED, 4)

rule "Mei frosty jet pack":
  @Event eachPlayer
  @Condition eventPlayer.getCurrentHero() == Hero.MEI
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.isInAir() == true
  
  eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), -2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
  wait(0.1)
  if RULE_CONDITION:
      goto RULE_START

rule "Brigitte Bash":
  @Event playerDealtDamage
  @Team 1
  @Hero brigitte
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventAbility == Button.PRIMARY_FIRE
  
  victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)