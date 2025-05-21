#!mainFile "main.opy"

rule "disable auto respawn": 
  @Event playerJoined

  eventPlayer.disableRespawn()
  # todo: fix?
  # if not isDebugAutoRespawn:

rule "Waiting for players ready":
  @Event eachPlayer
  @Team 1
  @Condition isGameStarted == false
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.CROUCH) 

  wait(0.5, Wait.ABORT_WHEN_FALSE)
  smallMessage(getAllPlayers(), "Match begins!")
  isGameStarted = true

rule "Match end":
  @Condition not isDebugAutoRespawn
  @Condition isGameStarted
  @Condition getNumberOfPlayers() > 1
  @Condition all(
    [player.isDead() or not player.hasSpawned() for player in getPlayers(Team.1)]
  )
  
  matchIsOver = true
  destroyAllEffects()
  destroyAllInWorldTexts()
  wait(3)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Survived", roundNumber, l"Rounds"))
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Total", l"{0}:".format(l"Score"), teamScore))
  wait(4)
  declareTeamVictory(Team.2)