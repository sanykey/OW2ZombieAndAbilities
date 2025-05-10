#!mainFile "main.opy"

rule "Crash Protection [ON]":
  @Condition getServerLoad() > 250
  @Condition highloadServerPause < getTotalTimeElapsed()
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  highloadServerPause = 10 + getTotalTimeElapsed()
  setSlowMotion(83)
  bigMessage(getPlayers(Team.1), "Too high load on the server. Short break!\n\n (Cur:{} / AVG: {}/ Max: {})".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()))
  isBotsDisabled = true
  for I in range(MAX_ZOMBIES):
    destroyDummy(Team.2, I)

  smallMessage(getPlayers(Team.1), "[debug] bot spawn poins len: {}".format(len(spawnPointsList)))

  wait(5, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(100)
  isBotsDisabled = false

rule "Crash Protection [ON]":
  @Condition getServerLoad() > 250
  @Condition roundNumber < 40
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(83)


rule "Crash Protection [OFF]":
  @Condition getAverageServerLoad() < 249
  @Condition roundNumber < 40
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(100)


rule "Crash Protection 40+ [ON]":
  @Condition getServerLoad() > 250
  @Condition getPlayers(Team.1).G[6] == false
  @Condition roundNumber > 39
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(83)


rule "Crash Protection 40+ [OFF]":
  @Condition getAverageServerLoad() < 249
  @Condition getPlayers(Team.1).G[6] == false
  @Condition roundNumber > 39
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(100)

rule "show ServerLoad info":
  hudSubheader(
    localPlayer if localPlayer == hostPlayer else false,
    "Server load: {0} / AVG: {1}/ Max: {2}".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()),
    HudPosition.RIGHT,
    -5,
    rgb(255, 280 - getAverageServerLoad(), 0),
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

# rule "Disable inspector recording - debug":
#   wait(1)
#   disableInspector()

rule "Unlimited match time":
  @Condition getMatchTime() < 10
  @Condition matchIsOver == false
  
  setMatchTime(3599)


