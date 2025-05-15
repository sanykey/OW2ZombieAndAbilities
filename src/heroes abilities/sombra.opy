#!mainFile "../main.opy"

rule "[Sombra] Init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SOMBRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 2
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg765dbdFF>Sombra</fg>:\n
  <TX C0000000000A6B6> <fg765dbdFF>Stealth:</fg>
      - Enemies will see you if you get too close in their line of sight (you can approach from behind undetected).
      - A melee stuns enemies and steals ${}\n\n
  {} <fg765dbdFF>Hack:</fg>
      - Allies and Sombra deal an additional 30% damage to hacked targets
      - Killing hacked enemies gives attackers an extra ${} and ${} for the rest of allies\n\n
  About vanilla Perks:
      - Minor <fg765dbdFF>Uncripted upload</fg> is useless, doesn't work in this mode
  ".format(
    heroIcon(Hero.SOMBRA),
    SOMBRA_STEAL_MONEY,
    abilityIconString(Hero.SOMBRA, Button.SECONDARY_FIRE),
    MONEY_FOR_KILL_HACKED,
    MONEY_FOR_KILL_HACKED_TEAM
  )

  waitUntil(eventPlayer.getHero() != Hero.SOMBRA, INFINITY)
  clearHeroInfo()


rule "[Sombra] Invisible detect":
  @Event eachPlayer
  @Team 1
  @Hero sombra
  @Condition eventPlayer.isUsingAbility2() == true
  
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
    eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(Team.2), 8) and
    isInLoS(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.2)) and
    distance(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.2)) <= 15 
  )
  eventPlayer.isInvisible = false

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