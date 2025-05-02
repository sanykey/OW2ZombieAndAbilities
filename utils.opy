#!mainFile "main.opy"

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

rule "shop ServerLoad info":
  @Condition roundNumber == 1
  
  isBotsDisabled = false
  # server loading stats:
  hudText(
    getPlayersInSlot(0, Team.1),
    getServerLoad(),
    getAverageServerLoad(),
    getPeakServerLoad(),
    HudPosition.RIGHT,
    -1,
    Color.GREEN,
    Color.ORANGE,
    Color.RED,
    HudReeval.VISIBILITY_AND_STRING
  )


rule "Disable inspector recording - debug":
  wait(1)
  disableInspector()

rule "Unlimited match time":
  @Condition getMatchTime() < 10
  @Condition matchIsOver == false
  
  setMatchTime(3599)


