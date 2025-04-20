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


# todo: debug
# rule "Disable inspector recording - debug":
#   wait(1)
#   disableInspector()

rule "Unlimited match time":
  @Condition getMatchTime() < 10
  @Condition match_is_over == false
  
  setMatchTime(3599)

rule "Create vips list":
  vips = ["snky"]

rule "Change character for vip":
  @Event eachPlayer
  @Condition eventPlayer.hasSpawned() == true
  @Condition eventPlayer.isAlive() == true
  @Condition "{0}".format(eventPlayer) in vips == true
  
  wait(2)
  eventPlayer.startForcingHero(Hero.JUNO)

  eventPlayer.stateArr[0] = 4
  smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")