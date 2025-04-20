#!mainFile "main.opy"

rule "Create revive effects":
  for I in range(MAX_PLAYERS):
    playersRessurectPositionsArr[I] = hiddenVector

  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[0], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[0], getPlayersInSlot(0, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[1], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[1], getPlayersInSlot(1, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[2], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[2], getPlayersInSlot(2, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[3], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[3], getPlayersInSlot(3, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[4], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[4], getPlayersInSlot(4, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, playersRessurectPositionsArr[5], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, playersRessurectPositionsArr[5], getPlayersInSlot(5, Team.1).reviveProgress, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "Player death":
  @Event playerDied
  @Team 1
  
  playersRessurectPositionsArr[eventPlayer.getSlot()] = nearestWalkablePosition(eventPlayer)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, l"{0}!".format("is down and needs reviving")))
  smallMessage(eventPlayer, "Please wait for a teammate to revive you or for all zombies to be slayed this round.")


rule "Revive player 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[0]) <= 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(0, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(0, Team.1).teleport(eventPlayer)
  getPlayersInSlot(0, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.YELLOW, playersRessurectPositionsArr[0], 100)
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, getPlayersInSlot(0, Team.1), 10)
  playersRessurectPositionsArr[0] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(0, Team.1), null, 100000)
  getPlayersInSlot(0, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[0]) > 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  
  getPlayersInSlot(0, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(0, Team.1).reviveProgress)


rule "Revive player 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[1]) <= 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(1, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(1, Team.1).teleport(eventPlayer)
  getPlayersInSlot(1, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, playersRessurectPositionsArr[1], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(1, Team.1), 100)
  playersRessurectPositionsArr[1] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(1, Team.1), null, 100000)
  getPlayersInSlot(1, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[1]) > 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  
  getPlayersInSlot(1, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(1, Team.1).reviveProgress)


rule "Revive player 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[2]) <= 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(2, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(2, Team.1).teleport(eventPlayer)
  getPlayersInSlot(2, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, playersRessurectPositionsArr[2], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(2, Team.1), 100)
  playersRessurectPositionsArr[2] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(2, Team.1), null, 100000)
  getPlayersInSlot(2, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[2]) > 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  
  getPlayersInSlot(2, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(2, Team.1).reviveProgress)


rule "Revive player 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[3]) <= 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(3, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(3, Team.1).teleport(eventPlayer)
  getPlayersInSlot(3, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, playersRessurectPositionsArr[3], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(3, Team.1), 100)
  playersRessurectPositionsArr[3] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(3, Team.1), null, 100000)
  getPlayersInSlot(3, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[3]) > 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  
  getPlayersInSlot(3, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(3, Team.1).reviveProgress)


rule "Revive player 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[4]) <= 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(4, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(4, Team.1).teleport(eventPlayer)
  getPlayersInSlot(4, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, playersRessurectPositionsArr[4], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(4, Team.1), 100)
  playersRessurectPositionsArr[4] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(4, Team.1), null, 100000)
  getPlayersInSlot(4, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[4]) > 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  
  getPlayersInSlot(4, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(4, Team.1).reviveProgress)


rule "Revive player 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[5]) <= 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  chaseOverTime(getPlayersInSlot(5, Team.1).reviveProgress, 4, 2 + playerRessurectTimeMult * 2)
  wait(2 + playerRessurectTimeMult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(5, Team.1).teleport(eventPlayer)
  getPlayersInSlot(5, Team.1).resurrect()
  playerRessurectTimeMult += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, playersRessurectPositionsArr[5], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(5, Team.1), 100)
  playersRessurectPositionsArr[5] = hiddenVector
  eventPlayer.money += MONEY_FOR_REVIVE * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(MONEY_FOR_REVIVE * eventPlayer.H, l"Points")))
  teamScore += MONEY_FOR_REVIVE * eventPlayer.H
  heal(getPlayersInSlot(5, Team.1), null, 100000)
  getPlayersInSlot(5, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "Cancel revive player 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, playersRessurectPositionsArr[5]) > 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  
  getPlayersInSlot(5, Team.1).reviveProgress = 0
  stopChasingVariable(getPlayersInSlot(5, Team.1).reviveProgress)


rule "Player respawn & move revive":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() == true
  
  playersRessurectPositionsArr[eventPlayer.getSlot()] = hiddenVector