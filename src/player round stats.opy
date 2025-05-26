#!mainFile "main.opy"

#!define MONEY_FOR_ELIMINATIONS 300
#!define MONEY_FOR_DAMAGE_DEALT 0.3
#!define MONEY_FOR_DAMAGE_BLOCKED 0.06
#!define MONEY_FOR_DAMAGE_TAKEN 0.05
#!define MONEY_FOR_DEFENSIVE_ASSISTS 150
#!define MONEY_FOR_ZERO_DEATHS 1000
#!define SHOW_ROUND_STATS_DURATION 10

playervar prevEliminations
playervar prevDamageDealtStat
playervar prevDamageBlockedStat
playervar prevDamageTakenStat
playervar prevDefensiveAssistsStat
playervar prevDeathsStat

playervar roundEliminations
playervar roundDamageDealtStat
playervar roundDamageBlockedStat
playervar roundDamageTakenStat
playervar roundDefensiveAssistsStat
playervar roundDeathsStat

globalvar showPlayerStatsTime



rule "calculate player round stats":
  @Event eachPlayer
  @Team 1
  @Condition roundRemainingBots < 1

  wait(0.5)
  eventPlayer.roundEliminations = eventPlayer.getStatistic(Stat.ELIMINATIONS) - eventPlayer.prevEliminations
  eventPlayer.prevEliminations = eventPlayer.getStatistic(Stat.ELIMINATIONS)

  eventPlayer.roundDamageDealtStat = eventPlayer.getStatistic(Stat.DAMAGE_DEALT) - eventPlayer.prevDamageDealtStat
  eventPlayer.prevDamageDealtStat = eventPlayer.getStatistic(Stat.DAMAGE_DEALT)

  eventPlayer.roundDamageBlockedStat = eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED) - eventPlayer.prevDamageBlockedStat
  eventPlayer.prevDamageBlockedStat = eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED)

  eventPlayer.roundDamageTakenStat = eventPlayer.getStatistic(Stat.DAMAGE_TAKEN) - eventPlayer.prevDamageTakenStat
  eventPlayer.prevDamageTakenStat = eventPlayer.getStatistic(Stat.DAMAGE_TAKEN)

  eventPlayer.roundDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) - eventPlayer.prevDefensiveAssistsStat
  eventPlayer.prevDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS)

  eventPlayer.roundDeathsStat = eventPlayer.getStatistic(Stat.DEATHS) - eventPlayer.prevDeathsStat
  eventPlayer.prevDeathsStat = eventPlayer.getStatistic(Stat.DEATHS)

  eventPlayer.money += eventPlayer.roundDamageDealtStat * MONEY_FOR_DAMAGE_DEALT
  eventPlayer.money += eventPlayer.roundDamageBlockedStat * MONEY_FOR_DAMAGE_BLOCKED
  eventPlayer.money += eventPlayer.roundDamageTakenStat * MONEY_FOR_DAMAGE_TAKEN
  eventPlayer.money += eventPlayer.roundDefensiveAssistsStat * MONEY_FOR_DEFENSIVE_ASSISTS
  eventPlayer.money += MONEY_FOR_ZERO_DEATHS if eventPlayer.roundDeathsStat == 0 else 0

  showPlayerStatsTime = getTotalTimeElapsed() + SHOW_ROUND_STATS_DURATION