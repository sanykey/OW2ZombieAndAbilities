#!mainFile "main.opy"

rule "Create ally bot":
  @Condition getPlayers(Team.1).hasSpawned() == true
  @Condition getNumberOfPlayers(Team.1) < MAX_PLAYERS
  wait(2)
  createDummy(Hero.ORISA, Team.1, 7, nearestWalkablePosition(getPlayersInSlot(0, Team.1)), getPlayersInSlot(0, Team.1).getPosition())
  getPlayersInSlot(7, Team.1).isCombatant = true
  updateCombatants()
  getPlayersInSlot(7, Team.1).healthStat += 1000
  getPlayersInSlot(7, Team.1).setMaxHealth(getPlayersInSlot(7, Team.1).healthStat)

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
    (vect(0, 0, 0) if eventPlayer.isTargetInLos else 1.5 * directionTowards(eventPlayer, eventPlayer.B)) + (directionTowards(eventPlayer.getEyePosition(), eventPlayer.B.getEyePosition() + 0.25 * Vector.UP)),
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
    eventPlayer.isTargetInLos = true
    eventPlayer.B = temp1
  else:
    eventPlayer.isTargetInLos = false
  wait(0.5)
  if ruleCondition:
    loop()


rule "Ally bot: Start / Stop Shooting":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition (eventPlayer.isTargetInLos and not eventPlayer.isMoving()) == true
  
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  waitUntil(not (eventPlayer.isTargetInLos and not eventPlayer.isMoving()), INFINITY)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
  
# todo: debug
rule "Teleport bot to died player":
  @Event eachPlayer
  @Team 1
  @Slot ALLY_BOT_PLAYER_SLOT
  @Condition any([player.downedStartTime == true for player in combatants]) == true

  temp1 = [player for player in combatants if player.downedStartTime][0]
  if temp1 == true:
    eventPlayer.teleport(temp1.getPosition())
