#!mainFile "main.opy"

rule "init utils":
  # Disable inspector recording
  disableInspector()

  # Show ServerLoad info
  hudSubheader(
    localPlayer if localPlayer == hostPlayer else null,
    "Server load: {} / AVG: {}/ Max: {}
      Entities: {}, Texts: {}
    ".format(
      getServerLoad(),
      getAverageServerLoad(),
      getPeakServerLoad(),
      getNumberOfEntityIds(),
      getNumberOfTextIds()
    ),
    HudPosition.RIGHT,
    -5,
    rgb(255, 280 - getAverageServerLoad(), 0),
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

rule "Server anti-crash system":
  @Condition getServerLoad() > 240
  
  wait(0.5, Wait.ABORT_WHEN_FALSE)
  if not ruleCondition:
    return

  smallMessage(getAllPlayers(), "[Server]: Anti crash system enabled to reduce server load")
  setSlowMotion(75)
  waitUntil(getServerLoad() < 230, INFINITY)
  setSlowMotion(100)


# rule "Crash Protection [ON]":
#   @Condition getServerLoad() > 250
#   @Condition highloadServerPause < getTotalTimeElapsed()
  
#   wait(2, Wait.ABORT_WHEN_FALSE)
#   highloadServerPause = 10 + getTotalTimeElapsed()
#   setSlowMotion(83)
#   bigMessage(getPlayers(Team.1), "Too high load on the server. Short break!\n\n (Cur:{} / AVG: {}/ Max: {})".format(getServerLoad(), getAverageServerLoad(), getPeakServerLoad()))
#   isBotsDisabled = true
#   for I in range(wSettingsMaxZombieBots):
#     destroyDummy(Team.2, I)

#   smallMessage(getPlayers(Team.1), "[debug] bot spawn poins len: {}".format(len(spawnPointsList)))

#   wait(5, Wait.ABORT_WHEN_FALSE)
#   setSlowMotion(100)
#   isBotsDisabled = false

# rule "Crash Protection [ON]":
#   @Condition getServerLoad() > 250
#   @Condition roundNumber < 40
  
#   wait(2, Wait.ABORT_WHEN_FALSE)
#   setSlowMotion(83)


# rule "Crash Protection [OFF]":
#   @Condition getAverageServerLoad() < 249
#   @Condition roundNumber < 40
  
#   wait(2, Wait.ABORT_WHEN_FALSE)
#   setSlowMotion(100)


# rule "Crash Protection 40+ [ON]":
#   @Condition getServerLoad() > 250
#   @Condition getPlayers(Team.1).G[6] == false
#   @Condition roundNumber > 39
  
#   wait(2, Wait.ABORT_WHEN_FALSE)
#   setSlowMotion(83)


# rule "Crash Protection 40+ [OFF]":
#   @Condition getAverageServerLoad() < 249
#   @Condition getPlayers(Team.1).G[6] == false
#   @Condition roundNumber > 39
  
#   wait(2, Wait.ABORT_WHEN_FALSE)
#   setSlowMotion(100)








