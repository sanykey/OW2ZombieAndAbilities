#!mainFile "main.opy"

rule "Crash Protection [ON]":
  @Condition getServerLoad() > 250
  @Condition newLine < 40
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(83)


rule "Crash Protection [OFF]":
  @Condition getAverageServerLoad() < 249
  @Condition newLine < 40
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(100)


rule "Crash Protection 40+ [ON]":
  @Condition getServerLoad() > 250
  @Condition getPlayers(Team.1).G[6] == false
  @Condition newLine > 39
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(83)


rule "Crash Protection 40+ [OFF]":
  @Condition getAverageServerLoad() < 249
  @Condition getPlayers(Team.1).G[6] == false
  @Condition newLine > 39
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  setSlowMotion(100)


rule "[Disable Inspector Recording - Debug]":
  wait(1)
  disableInspector()