#!mainFile "main.opy"

rule "Waiting for players ready":
  @Event eachPlayer
  @Team 1
  @Condition isGameStarted == false
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.CROUCH) 

  wait(0.5, Wait.ABORT_WHEN_FALSE)
  smallMessage(getAllPlayers(), "Match begins!")
  destroyHudText(delayerStartHudId)
  isGameStarted = true

rule "Match end":
  @Condition not isDebugAutoRespawn
  @Condition isGameStarted
  @Condition getNumberOfPlayers() > 1
  @Condition all(
    [player.isDead() or (not player.hasSpawned() and not player.posBeforeChangeHero) for player in getPlayers(Team.1)]
  )
  
  matchIsOver = true
  destroyAllEffects()
  destroyAllInWorldTexts()
  wait(3)
  bigMessage(getAllPlayers(), "Survived {} rounds".format(roundNumber))
  bigMessage(getAllPlayers(), "Total Score: {}".format(teamScore))
  wait(4)
  declareTeamVictory(Team.2)

rule "Unlimited match time":
  @Condition getMatchTime() < 10
  @Condition matchIsOver == false
  
  setMatchTime(3599)