#!mainFile "../main.opy"

rule "[Sombra] Init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SOMBRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = 1
  eventPlayer.heroInfoText0 = "{} <fg765dbdFF>Sombra</fg>:\n
  <TX C0000000000A6B6> <fg765dbdFF>Stealth:</fg>
      - Enemies will see you if you get too close in their line of sight
        (you can approach from behind undetected).
      - A melee stuns enemies and steals ${}\n\n
  {} <fg765dbdFF>Hack:</fg>
      - Allies and Sombra deal an additional 30% damage to hacked targets
      - Killing hacked enemies gives attackers an extra ${}\n\n
  About vanilla Perks:
      - Minor <fg765dbdFF>Uncripted upload</fg> is useless, doesn't work in this mode
  ".format(
    heroIcon(Hero.SOMBRA),
    SOMBRA_STEAL_MONEY,
    abilityIconString(Hero.SOMBRA, Button.SECONDARY_FIRE),
    70 # todo
  )

  waitUntil(eventPlayer.getHero() != Hero.SOMBRA, INFINITY)
  clearHeroInfo()


rule "[Sombra] Invisible detect":
  @Event eachPlayer
  @Team 1
  @Hero sombra
  @Condition eventPlayer.isUsingAbility2()
  
  wait(0.8, Wait.ABORT_WHEN_FALSE)
  eventPlayer.isInvisible = getTotalTimeElapsed() + 5
  waitUntil(eventPlayer.isFiringPrimaryFire() or eventPlayer.isUsingAbility1() or eventPlayer.isMeleeing(), 5)
  eventPlayer.isInvisible = false

rule "[Sombre] Stop invisible when hacking":
  @Event eachPlayer
  @Team 1
  @Hero sombra
  @Condition (
    eventPlayer.isFiringSecondaryFire() and
    eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES), 8) and
    isInLoS(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES)) and
    distance(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES)) <= 15 
  )
  eventPlayer.isInvisible = false

rule "[Sombra] Extra damage to hacked enemy (for all teammates)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatus(Status.HACKED)

  eventPlayer.setDamageReceived(130)
  eventPlayer.zomIsHacked = true # Needed so that on the playerEarnedElimination event, you can check whether the killed zombie was hacked before the kill.
  waitUntil(not eventPlayer.hasStatus(Status.HACKED) or eventPlayer.isDead(), INFINITY)
  eventPlayer.setDamageReceived(100)
  wait(0.1, Wait.RESTART_WHEN_TRUE)
  eventPlayer.zomIsHacked = false

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
#   eventPlayer.effectsIds__[1] = getLastCreatedEntity()
#   eventPlayer.Ability_Active = true
#   waitUntil(eventPlayer.isDead() or not eventPlayer.Talent1, 3)
#   eventPlayer.Damage_Dealt -= 50
#   destroyEffect(eventPlayer.effectsIds__[1])
#   eventPlayer.Ability_Active = false

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
#   damage(getPlayersInRadius(eventPlayer, 8, Team.ZOMBIES, LosCheck.SURFACES), eventPlayer, 50)
#   playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, eventPlayer.getEyePosition(), 20000)
#   playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.PURPLE, eventPlayer.getEyePosition(), 8)
#   playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.VIOLET, eventPlayer.getEyePosition(), 16)
#   getPlayersInRadius(eventPlayer.getEyePosition(), 8, Team.ZOMBIES, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.HACKED, 2)