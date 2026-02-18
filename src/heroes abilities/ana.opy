#!mainFile "../main.opy"

#!define ANA_SELF_NANO_DUMMY_BOT_SLOT 10

rule "[Ana] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.ANA

  eventPlayer.heroInfoVertFix0 = 2
  eventPlayer.heroInfoText0 = "{} <fg6e89b1FF>Ana</fg>:\n
  {} {}Sleep dart{}:
    - Hitting an enemy puts other enemies within a 4-meter radius to sleep.\n\n
  {} <fg6e89b1FF>Biotic gredane</fg>:
    - Slows enemies by 50%.\n\n
  {} {}Nano boost{}:
    - Can now be used on Ana herself.
    - Increases movement speed by 35%.\n\n
  Melee:
    - Has a 20% chance to put an enemy to sleep.
  ".format(
    heroIcon(Hero.ANA),
    abilityIconString(Hero.ANA, Button.ABILITY_1),
    "<fg6e89b1FF>",
    "</fg>",
    abilityIconString(Hero.ANA, Button.ABILITY_2),
    abilityIconString(Hero.ANA, Button.ULTIMATE),
    "<fg6e89b1FF>",
    "</fg>"
  )

  # Paralyzing Strike ability CD info:
  eventPlayer.abilityCDHud(
    "{}{} Paralyzing Strike: {}".format(
      ABILITI_TEXT_INTEND,
      abilityIconString(Hero.ANA, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>✓</fg> <fg94a0a544>(Press {})</fg>".format(inputBindingString(Button.MELEE))
    ),
    eventPlayer.heroEffectsIds[false]
  )

  # # Paralyzing Strike ability CD info:
  # hudText(
  #   eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
  #   null,
  #   "{}{} Paralyzing Strike: {}".format(
  #     ABILITI_TEXT_INTEND,
  #     abilityIconString(Hero.ANA, Button.ABILITY_1),
  #     ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>✓</fg> <fg94a0a544>(Press {})</fg>".format(inputBindingString(Button.MELEE))
  #   ),
  #   null,
  #   HudPosition.TOP,
  #   2.5,
  #   null,
  #   Color.WHITE,
  #   null
  # )
  # eventPlayer.heroEffectsIds[false] = getLastCreatedText()

  waitUntil(eventPlayer.getHero() != Hero.ANA, INFINITY)
  clearHeroInfo()
  destroyHudText(eventPlayer.heroEffectsIds[false])

rule "[Ana] Sleep effect":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatus(Status.ASLEEP)

  eventPlayer.setDamageReceived(150)
  waitUntil(not ruleCondition, INFINITY)
  eventPlayer.setDamageReceived(100)

rule "[Ana] Nano damage for detect":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isUsingUltimate()
  
  damage(getPlayers(eventPlayer.getTeam()).exclude(eventPlayer), null, 0.01)
  wait(0.2)
  heal(getPlayers(eventPlayer.getTeam()).exclude(eventPlayer), null, 0.01)


# eventPlayer.abilState0 - bool, is dummy bot created and is self using ultimate through dummy bot
# eventPlayer.abilState1 - entity: dummy bot
rule "[Ana] Self nano":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.isDummy()
  @Condition not eventPlayer.abilState0
  @Condition not eventPlayer.hasStatus(Status.HACKED)
  @Condition not eventPlayer.isCrowdControlled()
  
  waitUntil(
    eventPlayer.isUsingUltimate(), 3.5 if any([player.isAlive() and player != eventPlayer and eventPlayer.isInViewAngle(player, 10) for player in getPlayersInRadius(eventPlayer, 41, eventPlayer.getTeam(), LosCheck.SURFACES)]) else 0.13
  )

  if eventPlayer.isUsingUltimate():
    return 

  eventPlayer.abilState0 = true
  createDummy(Hero.ANA, eventPlayer.getTeam(), ANA_SELF_NANO_DUMMY_BOT_SLOT, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition(), Vector.DOWN)
  eventPlayer.abilState1 = getLastCreatedEntity()
  eventPlayer.abilState1 = eventPlayer.abilState1[0]
  eventPlayer.abilState1.startForcingPosition(updateEveryFrame(raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition()))
  eventPlayer.abilState1.startFacing(directionTowards(eventPlayer.abilState1.getEyePosition(), eventPlayer.getPosition()), 4000)
  eventPlayer.abilState1.startForcingName("■")
  eventPlayer.abilState1.disableEnvironmentCollision(true)
  eventPlayer.abilState1.setStatusEffect(eventPlayer, Status.PHASED_OUT, 9999)
  eventPlayer.abilState1.setInvisibility(Invis.ALL)
  eventPlayer.abilState1.setHealth(5)
  wait()
  eventPlayer.forceButtonPress(Button.ULTIMATE)
  eventPlayer.abilState1.setUltCharge(100)
  waitUntil(eventPlayer.isUsingUltimate(), 1)
  if eventPlayer.isUsingUltimate():
    eventPlayer.abilState1.stopForcingPosition()
    eventPlayer.abilState1.startForcingPosition(updateEveryFrame(eventPlayer.getEyePosition()))
    wait(0.025)
    eventPlayer.abilState1.forceButtonPress(Button.ULTIMATE)
    waitUntil(eventPlayer.abilState1.isUsingUltimate(), 0.25)
    if eventPlayer.abilState1.isUsingUltimate():
      eventPlayer.abilState1.stopForcingPosition()
      eventPlayer.abilState1.startForcingPosition(vect(false, 1000, false))
      waitUntil(not eventPlayer.isAlive(), 8)
      destroyDummy(eventPlayer.getTeam(), eventPlayer.abilState1.getSlot())
      eventPlayer.abilState0 = false
    elif not eventPlayer.abilState1.isUsingUltimate():
      destroyDummy(eventPlayer.getTeam(), 5)
      eventPlayer.abilState0 = false
  elif not eventPlayer.isUsingUltimate():
    destroyDummy(eventPlayer.getTeam(), 5)
    eventPlayer.abilState0 = false


# eventPlayer.abilState2 - is Ana attached to teammate
# eventPlayer.abilState3 - Player Ana is attached to
# eventPlayer.abilState4 - attach position
# rule "[Ana] ATTACH/DETATCH to another player":
#   @Event eachPlayer
#   @Team 1
#   @Hero ana
#   @Condition (
#     eventPlayer.isHoldingButton(Button.CROUCH) 
#     or (
#       eventPlayer.abilState2 and (
#         not eventPlayer.hasSpawned() 
#         or not eventPlayer.abilState3.hasSpawned()
#         or eventPlayer.isDead()
#         or eventPlayer.abilState3.isDead()
#         or not entityExists(eventPlayer.abilState3)
#         or eventPlayer.hasStatus(Status.KNOCKED_DOWN)
#         or eventPlayer.abilState3.hasStatus(Status.KNOCKED_DOWN)
#         or distance(eventPlayer.getPosition(), eventPlayer.abilState3.getPosition()) > 3
#       )
#     )
#   )
  
#   if not eventPlayer.abilState2 and eventPlayer.isAlive():
#     if any([not i.abilState2 and distance(eventPlayer.getPosition(), i.getPosition()) < 2 for i in combatants.exclude(eventPlayer)]):
#       #Select parent
#       eventPlayer.abilState3 = (
#         sorted([i for i in combatants.exclude(eventPlayer) if not i.isCrowdControlled() and distance(eventPlayer.getPosition(), i.getPosition()) < 2], lambda i: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), i.getEyePosition())))
#       )[0]

#       #World Vector
#       eventPlayer.abilState4 = eventPlayer.abilState3.getPosition() + directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.abilState3.getPosition(), eventPlayer.getPosition())), 0) * 1 + vect(0, 1, 0)
#       #Local vector conversion
#       eventPlayer.abilState4 = localVector(eventPlayer.abilState4, eventPlayer.abilState3, Transform.ROTATION_AND_TRANSLATION)
#       #Translate player behind parent
#       if eventPlayer.abilState4.z > 0:
#         eventPlayer.abilState4 *= vect(1, 1, -1)
#       eventPlayer.abilState2 = true
#       eventPlayer.attachTo(eventPlayer.abilState3, eventPlayer.abilState4)
#       smallMessage(eventPlayer, "You are attached")
#       # eventPlayer.abilState3.enhancementValues[13] = eventPlayer
#   else:
#     if entityExists(eventPlayer.abilState3) and eventPlayer.hasSpawned() and distance(eventPlayer.getPosition(), eventPlayer.abilState3.getPosition()) < 3:
#       eventPlayer.teleport(eventPlayer.abilState3.getPosition())
#     else:
#       eventPlayer.detach()
#     smallMessage(eventPlayer, "You have detached")
#     # eventPlayer.abilState3.enhancementValues[13] = null
#     eventPlayer.abilState2 = false
#     eventPlayer.abilState3 = false



rule "[Ana] splash damage and heal from scoped shot":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isFiringPrimaryFire()
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.tmp0 = raycast(
    eventPlayer.getEyePosition() + vect(false, -0.1, false),
    eventPlayer.getEyePosition() + vect(false, -0.1, false) + eventPlayer.getFacingDirection() * 100,
    [player for player in getPlayers() if player.isAlive() and (player.getTeam() == Team.ZOMBIES or (player.getTeam() == Team.1 and player.getHealth() < player.getMaxHealth()))],
    eventPlayer,
    true
  ).getHitPosition()

  eventPlayer.tmp1 = getPlayersInRadius(eventPlayer.tmp0, 2, Team.1, LosCheck.SURFACES).exclude(eventPlayer)

  if eventPlayer.tmp1:
    playEffect(getPlayers(eventPlayer.getTeam()), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer.tmp0, 1.3)
    # playEffect(getPlayers(getOppositeTeam(eventPlayer.getTeam())), DynamicEffect.GOOD_EXPLOSION, Color.VIOLET, eventPlayer.tmp0, 1.3)
    heal(eventPlayer.tmp1, eventPlayer, 20)

