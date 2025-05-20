#!mainFile "../main.opy"

#!define ROUND_START_DELAY 5
#!define MAX_REMAINING_ZOMBIES_IN_ROUND 40

rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
  bigMessage(getAllPlayers(), l"Round {0}".format(roundNumber))
  setObjectiveDescription(localPlayer, "Round {}".format(roundNumber), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  
  # Resurrect and heal all players
  temp2 = [player for player in getPlayers(Team.1) if player.downedStartTime]
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

  wait()
  heal(getPlayers(Team.1), null, INFINITY)
  wait(ROUND_START_DELAY)
  bigMessage(getAllPlayers(), "Starting Round!")
  
  getPlayers(Team.2).setMaxHealth(botsHealthBoostPercent)
  getPlayers(Team.2).setDamageDealt(botsDamageBoostPercent)

  # As soon as the "roundRemainingBots" is greater than 0 they will start respawning again
  roundRemainingBots = (
    wSettingsMaxZombieBots + roundNumber if (wSettingsMaxZombieBots + roundNumber) < MAX_REMAINING_ZOMBIES_IN_ROUND else MAX_REMAINING_ZOMBIES_IN_ROUND
  )
