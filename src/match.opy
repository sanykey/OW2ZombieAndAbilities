#!mainFile "main.opy"

#!define ROUND_START_DELAY 7
#!define MAX_REMAINING_ZOMBIES_IN_ROUND 80

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

rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  @Condition not isBotsDisabled
  
  roundNumber += 1
  
  bigMessage(getAllPlayers(), "Round {}".format(roundNumber))
  setObjectiveDescription(localPlayer, "Round {}, Team score: {}".format(roundNumber, teamScore), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  
  # Resurrect and heal all players
  temp2 = [player for player in getPlayers(Team.1) if player.downedStartTime or not player.isAlive()]
  if temp2:
    temp2.teleport(nearestWalkablePosition(random.choice(getLivingPlayers(Team.1)) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
    temp2.downedStartTime = false
    temp2.resurrect()

  botsHealthBoostPercent = (
    ZOMBIE_BASE_HP + 10 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)))
  )
  botsDamageBoostPercent = (
    ZOMBIE_BASE_DAMAGE + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)))
  )
  getPlayers(Team.2).setMaxHealth(botsHealthBoostPercent)
  getPlayers(Team.2).setDamageDealt(botsDamageBoostPercent)

  wait()
  heal(getPlayers(Team.1), null, INFINITY)
  wait(ROUND_START_DELAY)
  bigMessage(getPlayers(Team.1), "Starting Round!")
  # wait() # At the start of the round, bots spawn with incomplete health after the max health buff. This respawn delay is an attempt to fix that
  # # As soon as the "roundRemainingBots" is greater than 0 they will start respawning again
  roundRemainingBots = (
    wSettingsMaxZombieBots + roundNumber if (wSettingsMaxZombieBots + roundNumber) < MAX_REMAINING_ZOMBIES_IN_ROUND else MAX_REMAINING_ZOMBIES_IN_ROUND
  )
  roundMaxBots = roundRemainingBots

