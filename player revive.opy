#!mainFile "main.opy"
rule "[Revive Effects]":
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[0], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[0], getPlayersInSlot(0, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[1], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[1], getPlayersInSlot(1, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[2], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[2], getPlayersInSlot(2, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[3], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[3], getPlayersInSlot(3, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[4], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[4], getPlayersInSlot(0, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[5], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[5], getPlayersInSlot(1, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "[Revive Player A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[0]) <= 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(0, Team.1)
  chaseOverTime(getPlayersInSlot(0, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(0, Team.1).teleport(eventPlayer)
  getPlayersInSlot(0, Team.1).resurrect()
  P += 1
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.YELLOW, S[0], 100)
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, getPlayersInSlot(0, Team.1), 10)
  S[0] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).O = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(0, Team.1), null, 100000)
  getPlayersInSlot(0, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[0]) > 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  
  getPlayersInSlot(0, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(0, Team.1).C)


rule "[Revive Player B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[1]) <= 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(1, Team.1)
  chaseOverTime(getPlayersInSlot(1, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(1, Team.1).teleport(eventPlayer)
  getPlayersInSlot(1, Team.1).resurrect()
  P += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[1], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(1, Team.1), 100)
  S[1] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).P = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(1, Team.1), null, 100000)
  getPlayersInSlot(1, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[1]) > 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  
  getPlayersInSlot(1, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(1, Team.1).C)


rule "[Revive Player C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[2]) <= 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(2, Team.1)
  chaseOverTime(getPlayersInSlot(2, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(2, Team.1).teleport(eventPlayer)
  getPlayersInSlot(2, Team.1).resurrect()
  P += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[2], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(2, Team.1), 100)
  S[2] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).Q = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(2, Team.1), null, 100000)
  getPlayersInSlot(2, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[2]) > 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  
  getPlayersInSlot(2, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(2, Team.1).C)


rule "[Revive Player D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[3]) <= 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(3, Team.1)
  chaseOverTime(getPlayersInSlot(3, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(3, Team.1).teleport(eventPlayer)
  getPlayersInSlot(3, Team.1).resurrect()
  P += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[3], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(3, Team.1), 100)
  S[3] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).R = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(3, Team.1), null, 100000)
  getPlayersInSlot(3, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[3]) > 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  
  getPlayersInSlot(3, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(3, Team.1).C)


rule "[Revive Player E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[4]) <= 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(4, Team.1)
  chaseOverTime(getPlayersInSlot(4, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(4, Team.1).teleport(eventPlayer)
  getPlayersInSlot(4, Team.1).resurrect()
  P += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[4], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(4, Team.1), 100)
  S[4] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).Q = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(4, Team.1), null, 100000)
  getPlayersInSlot(4, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[4]) > 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  
  getPlayersInSlot(4, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(4, Team.1).C)


rule "[Revive Player F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[5]) <= 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(5, Team.1)
  chaseOverTime(getPlayersInSlot(5, Team.1).C, 4, 2 + P * 2)
  wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(5, Team.1).teleport(eventPlayer)
  getPlayersInSlot(5, Team.1).resurrect()
  P += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[5], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(5, Team.1), 100)
  S[5] = vect(500, 0, 500)
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).Q = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(5, Team.1), null, 100000)
  getPlayersInSlot(5, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, S[5]) > 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  
  getPlayersInSlot(5, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(5, Team.1).C)


rule "[Player Respawn & Move Revive]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() == true
  
  S[eventPlayer.getSlot()] = vect(500, 0, 500)