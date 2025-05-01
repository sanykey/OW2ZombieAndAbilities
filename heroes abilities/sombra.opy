#!mainFile "../main.opy"

# rule "[Sombra] Hack+":
#   @Event eachPlayer
#   @Team 2
#   @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
  
#   eventPlayer.setStatusEffect(null, Status.STUNNED, 2.5)
#   smallMessage(getPlayersOnHero(Hero.SOMBRA, Team.1), "Hack+ Activated: Stun")

rule "[Sombra] Init":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.SOMBRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 2
  waitUntil(eventPlayer.getHero() != Hero.SOMBRA, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.talentText[0] = ""


rule "[Sombra] Extra damage to hacked enemy (for all teammates)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatusEffect(Status.HACKED) == true
  eventPlayer.setDamageReceived(150)
  eventPlayer.state[SI.HACKED] = true
  waitUntil(eventPlayer.hasStatus(Status.HACKED) == false, INFINITY)
  eventPlayer.setDamageReceived(100)
  wait(0.1, Wait.RESTART_WHEN_TRUE)
  eventPlayer.state[SI.HACKED] = false

# rule "Team 1 Sombra: Stealth (Invisibility 1, detectable), end after 20 seconds":
#   @Event eachPlayer
#   @Team 1
#   @Hero sombra
#   @Condition eventPlayer.isUsingAbility1() == true
  
#   wait(0.8, Wait.ABORT_WHEN_FALSE)
#   eventPlayer.is_invisible = 1
#   for eventPlayer.sombra_stealth_timer in range(100, 0, -0.48):
#     waitUntil(not eventPlayer.isUsingAbility1(), 0.096)
#     if not eventPlayer.isUsingAbility1():
#         break
#   if eventPlayer.isUsingAbility1():
#     eventPlayer.forceButtonPress(Button.ABILITY_1)
#   eventPlayer.is_invisible = false

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
# rule "[Sombra] Stack Overflow - melee":
#   @Event playerDealtKnockback
#   @Team 1
#   @Hero sombra
#   @Condition eventPlayer.Talent1 == true
#   @Condition eventPlayer.Ability_Active == true
#   @Condition eventAbility == Button.MELEE
  
#   victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
#   damage(victim, eventPlayer, 40)
#   playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.PURPLE, victim, 0.25)

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