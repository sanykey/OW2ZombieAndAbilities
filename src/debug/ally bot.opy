#!mainFile "../main.opy"

rule "Create ally bot":
  @Condition hostPlayer.hasSpawned()
  
  wait(2)
  createDummy(Hero.ORISA, Team.1, ALLY_BOT_PLAYER_SLOT, nearestWalkablePosition(hostPlayer), hostPlayer.getPosition())

# rule "Destroy ally bot when max players":
#   @Event eachPlayer
#   @Team 1
#   @Slot ALLY_BOT_PLAYER_SLOT
#   @Condition getNumberOfPlayers(Team.1) == MAX_PLAYERS
#   destroyDummy(Team.1, ALLY_BOT_PLAYER_SLOT)

rule "Ally bot: Start Facing":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT

  eventPlayer.startForcingName("Kitty")
  eventPlayer.isReady = true
  eventPlayer.healthBoostPercent += 10000
  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  eventPlayer.damageBoostPercent = 10000
  eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
  eventPlayer.targetPlayer0 = getPlayers(Team.2)[0]
  eventPlayer.startFacing(
    (vect(0, 0, 0) if eventPlayer.abilState0 else 1.5 * directionTowards(eventPlayer, eventPlayer.targetPlayer0)) + (directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition() + 0.25 * Vector.UP)),
    300
  )

rule "Ally bot: Find Target":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT

  eventPlayer.temp0 = (
    sorted(
      [player for player in getLivingPlayers(Team.2) if (not player.hasStatus(Status.ASLEEP)) and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition() + 0.5 * Vector.DOWN)],
      lambda i: ((0.25 if i == eventPlayer.targetPlayer0 else 1) * distance(eventPlayer, i))
    )
  )[0]
  if eventPlayer.temp0:
    eventPlayer.abilState0 = true
    eventPlayer.targetPlayer0 = eventPlayer.temp0
  else:
    eventPlayer.abilState0 = false
  wait(0.5)
  if ruleCondition:
    loop()


rule "Ally bot: Start / Stop Shooting":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition (eventPlayer.abilState0 and not eventPlayer.isMoving())
  
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  waitUntil(not (eventPlayer.abilState0 and not eventPlayer.isMoving()), INFINITY)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
  
rule "Teleport bot to died player":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition any([player.downedStartTime == true for player in getPlayers(Team.1)])

  temp1 = [player for player in getPlayers(Team.1) if player.downedStartTime][0]
  if temp1 == true:
    eventPlayer.teleport(temp1.getPosition())
