#!mainFile "main.opy"

rule "Create ally bot":
  @Condition getPlayers(Team.1).hasSpawned() == true
  @Condition getNumberOfPlayers(Team.1) < MAX_PLAYERS
  wait(2)
  createDummy(Hero.ORISA, Team.1, 7, nearestWalkablePosition(getPlayersInSlot(0, Team.1)), getPlayersInSlot(0, Team.1).getPosition())
  getPlayersInSlot(7, Team.1).healthBoostPercent += 10000
  getPlayersInSlot(7, Team.1).setMaxHealth(getPlayersInSlot(7, Team.1).healthBoostPercent)

rule "Destroy ally bot when max players":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition getNumberOfPlayers(Team.1) == MAX_PLAYERS
  destroyDummy(Team.1, ALLY_BOT_PLAYER_SLOT)


rule "Ally bot: Start Facing":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  eventPlayer.startForcingName("Kitty")
  eventPlayer.B = getPlayers(Team.2)[0]
  eventPlayer.startFacing(
    (vect(0, 0, 0) if eventPlayer.abilState0 else 1.5 * directionTowards(eventPlayer, eventPlayer.B)) + (directionTowards(eventPlayer.getEyePosition(), eventPlayer.B.getEyePosition() + 0.25 * Vector.UP)),
    300
  )

rule "Ally bot: Find Target":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT

  temp1 = (
    sorted(
      [player for player in getLivingPlayers(Team.2) if (not player.hasStatus(Status.ASLEEP)) and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition() + 0.5 * Vector.DOWN)],
      lambda i: ((0.25 if i == eventPlayer.B else 1) * distance(eventPlayer, i))
    )
  )[0]
  if temp1:
    eventPlayer.abilState0 = true
    eventPlayer.B = temp1
  else:
    eventPlayer.abilState0 = false
  wait(0.5)
  if ruleCondition:
    loop()


rule "Ally bot: Start / Stop Shooting":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition (eventPlayer.abilState0 and not eventPlayer.isMoving()) == true
  
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  waitUntil(not (eventPlayer.abilState0 and not eventPlayer.isMoving()), INFINITY)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
  
# todo: debug
rule "Teleport bot to died player":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition any([player.downedStartTime == true for player in getPlayers(Team.1)]) == true

  temp1 = [player for player in getPlayers(Team.1) if player.downedStartTime][0]
  if temp1 == true:
    eventPlayer.teleport(temp1.getPosition())
