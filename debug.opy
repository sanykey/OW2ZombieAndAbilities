#!mainFile "main.opy"

rule "[debug] Add money and health":
  @Event playerJoined
  @Team 1
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 1000000
  eventPlayer.health_stat += 500
  eventPlayer.setMaxHealth(eventPlayer.health_stat)

rule "Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
  # @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    round_remaining_bots += 12
    damage(getPlayers(Team.2), getPlayers(Team.2), 99999)
    smallMessage(eventPlayer, "Bots disabled")
  else:
    isBotsDisabled = false
    smallMessage(eventPlayer, "Bots enabled")


rule "Init":
  isBotsDisabled = false
  # server loading stats:
  hudText(getPlayersInSlot(0, Team.1), getServerLoad(), getAverageServerLoad(), getPeakServerLoad(), HudPosition.LEFT, 7, Color.GREEN, Color.ORANGE, Color.RED, HudReeval.VISIBILITY_AND_STRING)
  # Player 1 current coordinates
  hudSubtext(getPlayersInSlot(0, Team.1), "P1 Coords: {0}".format(getPlayersInSlot(0, Team.1).getPosition()), HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


# rule "Teleport to shop":
#   @Condition roundNumber == 1
#   # todo: debug
#   createEffect(getAllPlayers(), Effect.SPHERE, Color.GREEN, vect(74.955, 13.858, -52.677), 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
#   createEffect(getAllPlayers(), Effect.SPHERE, Color.YELLOW, vect(75.589, 13.865, -50.533), 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
#   # wait(15)
#   getPlayers(Team.1)[0].teleport(vect(80.335, 13.93, -72.643))