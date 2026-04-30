#!mainFile "../main.opy"
#!optimizeForSize

rule "[Ana] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.ANA
  
  setHeroInfoText0(
    f"{heroIcon(Hero.ANA)} <fg6e89b1FF>Ana</fg>:\n
    {abilityIconString(Hero.ANA, Button.ABILITY_1)} <fg6e89b1FF>Sleep dart</fg>:
      - Hitting an enemy puts other enemies within a 4-meter radius to sleep.\n\n
    {abilityIconString(Hero.ANA, Button.ABILITY_2)} <fg6e89b1FF>Biotic gredane</fg>:
      - Slows enemies by 50%.\n\n
    {abilityIconString(Hero.ANA, Button.ULTIMATE)} <fg6e89b1FF>Nano boost</fg>:
      - Can now be used on Ana herself.
      - Increases movement speed by 35%.\n\n
    Melee:
      - Has a 20% chance to put an enemy to sleep.
    ", 2
  )

  # Paralyzing Strike ability CD info:
  eventPlayer.abilityCDHud(
    "{}{} Paralyzing Strike: {}".format(
      ABILITI_TEXT_INTEND,
      abilityIconString(Hero.ANA, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else f"<fgA0E81BFF>Melee hit</fg>"
    ),
    eventPlayer.heroEffectsIds[0]
  )

  waitUntil(eventPlayer.getHero() != Hero.ANA, INFINITY) # InfinityConst
  clearHeroInfoSub()
  destroyHudText(eventPlayer.heroEffectsIds[0])

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

rule "[Ana] Self nano":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.isDummy()
  @Condition not eventPlayer.heroState0
  @Condition not eventPlayer.hasStatus(Status.HACKED)
  @Condition not eventPlayer.isCrowdControlled()
  
  waitUntil(
    eventPlayer.isUsingUltimate(), 3.5 if any([player.isAlive() and player != eventPlayer and eventPlayer.isInViewAngle(player, 10) for player in getPlayersInRadius(eventPlayer, 41, eventPlayer.getTeam(), LosCheck.SURFACES)]) else 0.13
  )

  if eventPlayer.isUsingUltimate():
    return 

  createDummy(Hero.ANA, eventPlayer.getTeam(), -1, raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition(), Vector.DOWN)
  eventPlayer.heroState0 = getLastCreatedEntity()
  eventPlayer.heroState0 = eventPlayer.heroState0[0]
  eventPlayer.heroState0.startForcingPosition(updateEveryFrame(raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition()))
  eventPlayer.heroState0.startFacing(directionTowards(eventPlayer.heroState0.getEyePosition(), eventPlayer.getPosition()), 4000)
  eventPlayer.heroState0.startForcingName("■")
  eventPlayer.heroState0.disableEnvironmentCollision(true)
  eventPlayer.heroState0.setStatusEffect(eventPlayer, Status.PHASED_OUT, 9999)
  eventPlayer.heroState0.setInvisibility(Invis.ALL)
  eventPlayer.heroState0.setHealth(5)
  wait()
  eventPlayer.forceButtonPress(Button.ULTIMATE)
  eventPlayer.heroState0.setUltCharge(100)
  waitUntil(eventPlayer.isUsingUltimate(), 1)

  if eventPlayer.isUsingUltimate():
    eventPlayer.heroState0.stopForcingPosition()
    eventPlayer.heroState0.startForcingPosition(updateEveryFrame(eventPlayer.getEyePosition()))
    wait(0.025)
    eventPlayer.heroState0.forceButtonPress(Button.ULTIMATE)
    waitUntil(eventPlayer.heroState0.isUsingUltimate(), 0.25)
    if eventPlayer.heroState0.isUsingUltimate():
      eventPlayer.heroState0.stopForcingPosition()
      eventPlayer.heroState0.startForcingPosition(vect(false, 1000, false))
      waitUntil(not eventPlayer.isAlive(), 8)

  destroyDummy(eventPlayer.getTeam(), eventPlayer.heroState0.getSlot())
  eventPlayer.heroState0 = null


rule "[Ana] splash damage and heal from scoped shot":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isFiringPrimaryFire()
  @Condition eventPlayer.isFiringSecondaryFire()

  tmp0 = raycast(
    eventPlayer.getEyePosition() + vect(false, -0.1, false),
    eventPlayer.getEyePosition() + vect(false, -0.1, false) + eventPlayer.getFacingDirection() * 100,
    [player for player in getPlayers() if player.isAlive() and (player.getTeam() == Team.ZOMBIES or (player.getTeam() == Team.1 and player.getHealth() < player.getMaxHealth()))],
    eventPlayer,
    true
  ).getHitPosition()

  tmp1 = getPlayersInRadius(tmp0, 2, Team.1, LosCheck.SURFACES).exclude(eventPlayer)

  if tmp1:
    playEffect(getPlayers(eventPlayer.getTeam()), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, tmp0, 1.3)
    # playEffect(getPlayers(getOppositeTeam(eventPlayer.getTeam())), DynamicEffect.GOOD_EXPLOSION, Color.VIOLET, tmp0, 1.3)
    heal(tmp1, eventPlayer, 20)


# eventPlayer.heroState1 - is Ana attached to teammate
# eventPlayer.heroState2 - Player Ana is attached to
# eventPlayer.heroState3 - attach position
# rule "[Ana] ATTACH/DETATCH to another player":
#   @Event eachPlayer
#   @Team 1
#   @Hero ana
#   @Condition (
#     eventPlayer.isHoldingButton(Button.CROUCH) 
#     or (
#       eventPlayer.heroState1 and (
#         not eventPlayer.hasSpawned() 
#         or not eventPlayer.heroState2.hasSpawned()
#         or eventPlayer.isDead()
#         or eventPlayer.heroState2.isDead()
#         or not entityExists(eventPlayer.heroState2)
#         or eventPlayer.hasStatus(Status.KNOCKED_DOWN)
#         or eventPlayer.heroState2.hasStatus(Status.KNOCKED_DOWN)
#         or distance(eventPlayer.getPosition(), eventPlayer.heroState2.getPosition()) > 3
#       )
#     )
#   )
  
#   if not eventPlayer.heroState1 and eventPlayer.isAlive():
#     if any([not i.abilState2 and distance(eventPlayer.getPosition(), i.getPosition()) < 2 for i in combatants.exclude(eventPlayer)]):
#       #Select parent
#       eventPlayer.heroState2 = (
#         sorted([i for i in combatants.exclude(eventPlayer) if not i.isCrowdControlled() and distance(eventPlayer.getPosition(), i.getPosition()) < 2], lambda i: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), i.getEyePosition())))
#       )[0]

#       #World Vector
#       eventPlayer.heroState3 = eventPlayer.heroState2.getPosition() + directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.heroState2.getPosition(), eventPlayer.getPosition())), 0) * 1 + vect(0, 1, 0)
#       #Local vector conversion
#       eventPlayer.heroState3 = localVector(eventPlayer.heroState3, eventPlayer.heroState2, Transform.ROTATION_AND_TRANSLATION)
#       #Translate player behind parent
#       if eventPlayer.heroState3.z > 0:
#         eventPlayer.heroState3 *= vect(1, 1, -1)
#       eventPlayer.heroState1 = true
#       eventPlayer.attachTo(eventPlayer.heroState2, eventPlayer.heroState3)
#       smallMessage(eventPlayer, "You are attached")
#       # eventPlayer.heroState2.enhancementValues[13] = eventPlayer
#   else:
#     if entityExists(eventPlayer.heroState2) and eventPlayer.hasSpawned() and distance(eventPlayer.getPosition(), eventPlayer.heroState2.getPosition()) < 3:
#       eventPlayer.teleport(eventPlayer.heroState2.getPosition())
#     else:
#       eventPlayer.detach()
#     smallMessage(eventPlayer, "You have detached")
#     # eventPlayer.heroState2.enhancementValues[13] = null
#     eventPlayer.heroState1 = false
#     eventPlayer.heroState2 = false




