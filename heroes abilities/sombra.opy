#!mainFile "../main.opy"

# rule "[Sombra] Hack+":
#   @Event eachPlayer
#   @Team 2
#   @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
  
#   eventPlayer.setStatusEffect(null, Status.STUNNED, 2.5)
#   smallMessage(getPlayersOnHero(Hero.SOMBRA, Team.1), "Hack+ Activated: Stun")

rule "[Sombra] Init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SOMBRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 2
  waitUntil(eventPlayer.getHero() != Hero.SOMBRA, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.talentText[0] = ""


rule "[Sombra] Invisible detect":
  @Event eachPlayer
  @Team 1
  @Hero sombra
  @Condition eventPlayer.isUsingAbility2() == true
  
  wait(0.8, Wait.ABORT_WHEN_FALSE)
  eventPlayer.state[SI.IS_INVISIBLE] = true
  smallMessage(getAllPlayers(), "Invis start!")
  waitUntil(eventPlayer.isFiringPrimaryFire() or eventPlayer.isUsingAbility1() or eventPlayer.isMeleeing(), 5)
  eventPlayer.state[SI.IS_INVISIBLE] = false
  smallMessage(getAllPlayers(), "Invis end!")

rule "[Sombre] Stop invisible when hacking":
  @Event eachPlayer
  @Team 1
  @Hero sombra
  @Condition eventPlayer.isFiringSecondaryFire() == true



rule "[Sombra] Extra damage to hacked enemy (for all teammates)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
  eventPlayer.setDamageReceived(130)
  eventPlayer.state[SI.HACKED] = true # for money
  waitUntil(eventPlayer.hasStatus(Status.HACKED) == false, INFINITY)
  eventPlayer.setDamageReceived(100)
  wait(0.1, Wait.RESTART_WHEN_TRUE)
  eventPlayer.state[SI.HACKED] = false

# From "Heat Street PvE Talents" (KFVAY)
# rule "[Sombra] Stack Overflow":
#   @Event eachPlayer
#   @Team 1
#   @Hero sombra
#   @Condition eventPlayer.isUsingAbility1() == true
  
#   wait(0.8, Wait.ABORT_WHEN_FALSE)
#   waitUntil(
#     eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isHoldingButton(Button.ULTIMATE) or eventPlayer.isHoldingButton(Button.MELEE) or eventPlayer.isCommunicatingEmote(),
#     INFINITY
#   )
#   eventPlayer.cancelPrimaryAction()
#   createEffect(eventPlayer, Effect.MERCY_DAMAGE_BOOSTED, Color.TEAM_1, eventPlayer, 1)
#   eventPlayer.Damage_Dealt += 50
#   eventPlayer.Effects__[1] = getLastCreatedEntity()
#   eventPlayer.Ability_Active = true
#   waitUntil(eventPlayer.isDead() or not eventPlayer.Talent1, 3)
#   eventPlayer.Damage_Dealt -= 50
#   destroyEffect(eventPlayer.Effects__[1])
#   eventPlayer.Ability_Active = false

# # From "Heat Street PvE Talents" (KFVAY)
rule "[Sombra] melee from invisible":
  @Event playerDealtKnockback
  @Team 1
  @Hero sombra
  @Condition eventPlayer.state[SI.IS_INVISIBLE] == true
  @Condition eventAbility == Button.MELEE
  
  victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
  damage(victim, eventPlayer, 40)
  playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.PURPLE, victim, 0.25)
  smallMessage(eventPlayer, "{0} points".format(25 * eventPlayer.H))
  eventPlayer.money += 25 * eventPlayer.H

# # From "Heat Street PvE Talents" (KFVAY)
# rule "[Sombra] Cyberattack":
#   @Event eachPlayer
#   @Team 1
#   @Hero sombra
#   @Condition eventPlayer.Talent2 == true
#   @Condition eventPlayer.isUsingAbility2() == true
  
#   waitUntil(not eventPlayer.isUsingAbility2(), INFINITY)
#   if eventPlayer.isHoldingButton(Button.INTERACT):
#       return
#   if eventPlayer.isDead():
#       return
#   wait(0.25)
#   damage(getPlayersInRadius(eventPlayer, 8, Team.2, LosCheck.SURFACES), eventPlayer, 50)
#   playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, eventPlayer.getEyePosition(), 20000)
#   playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.PURPLE, eventPlayer.getEyePosition(), 8)
#   playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.VIOLET, eventPlayer.getEyePosition(), 16)
#   getPlayersInRadius(eventPlayer.getEyePosition(), 8, Team.2, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.HACKED, 2)