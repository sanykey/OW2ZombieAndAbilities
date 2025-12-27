#!mainFile "main.opy"

#!define MONEY_FOR_ELIMINATIONS 120
#!define MONEY_FOR_ELIMINATIONS_TEAM 80
#!define MONEY_FOR_OFFENSIVE_ASSISTS 120
#!define MONEY_FOR_DEFENSIVE_ASSISTS 120

#!define MONEY_FOR_HACKED_ELIMS 75
#!define MONEY_FOR_MELEE_FINAL_BLOW 75
#!define MONEY_FOR_CRITICAL_FINAL_BLOW 75

#!define MONEY_FOR_REVIVE 500

#!define MONEY_FOR_DAMAGE_DEALT 0.2
#!define MONEY_FOR_DAMAGE_BLOCKED 0.1
#!define MONEY_FOR_DAMAGE_TAKEN 0.1

#!define MONEY_FOR_ZERO_DEATHS 1500
#!define SHOW_ROUND_STATS_DURATION 10
#!define MONEY_FOR_HEALING 0.6
#!define MONEY_FOR_SELF_HEALING 0.3

playervar prevEliminations
playervar prevDamageDealtStat
playervar prevDamageBlockedStat
playervar prevDamageTakenStat
playervar prevDefensiveAssistsStat
playervar prevOffensiveAssistsStat
playervar prevDeathsStat

playervar healingCurrentStat
playervar selfHealingCurrentStat

playervar currentHackedElims
playervar currentMeleeFinalBlows
playervar currentCriticalFinalBlows

playervar roundEliminations
playervar roundTeamEliminatedBots
playervar roundHackedElims
playervar roundMeleeFinalBlows
playervar roundCriticalFinalBlows

playervar roundDamageDealtStat
playervar roundDamageBlockedStat
playervar roundDamageTakenStat
playervar roundDefensiveAssistsStat
playervar roundOffensiveAssistsStat

playervar roundRevivesStat
playervar roundDeathsStat
playervar roundHealingStat
playervar roundSelfHealingStat

globalvar showPlayerStatsTime

rule "calculate player round stats":
  @Event eachPlayer
  @Team 1
  @Condition roundRemainingBots < 1 and roundNumber > 1

  wait(0.5)

  eventPlayer.roundEliminations = eventPlayer.getStatistic(Stat.ELIMINATIONS) - eventPlayer.prevEliminations
  eventPlayer.prevEliminations = eventPlayer.getStatistic(Stat.ELIMINATIONS)

  eventPlayer.roundDamageDealtStat = eventPlayer.getStatistic(Stat.DAMAGE_DEALT) - eventPlayer.prevDamageDealtStat
  eventPlayer.prevDamageDealtStat = eventPlayer.getStatistic(Stat.DAMAGE_DEALT)

  eventPlayer.roundDamageBlockedStat = eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED) - eventPlayer.prevDamageBlockedStat
  eventPlayer.prevDamageBlockedStat = eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED)

  eventPlayer.roundDamageTakenStat = eventPlayer.getStatistic(Stat.DAMAGE_TAKEN) - eventPlayer.prevDamageTakenStat
  eventPlayer.prevDamageTakenStat = eventPlayer.getStatistic(Stat.DAMAGE_TAKEN)

  eventPlayer.roundOffensiveAssistsStat = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS) - eventPlayer.prevOffensiveAssistsStat
  eventPlayer.prevOffensiveAssistsStat = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS)

  eventPlayer.roundDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) - eventPlayer.prevDefensiveAssistsStat
  eventPlayer.prevDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS)

  eventPlayer.roundDeathsStat = eventPlayer.getStatistic(Stat.DEATHS) - eventPlayer.prevDeathsStat
  eventPlayer.prevDeathsStat = eventPlayer.getStatistic(Stat.DEATHS)

  eventPlayer.roundTeamEliminatedBots = roundMaxBots

  eventPlayer.roundHealingStat = eventPlayer.healingCurrentStat
  eventPlayer.healingCurrentStat = null
  eventPlayer.roundSelfHealingStat = eventPlayer.selfHealingCurrentStat
  eventPlayer.selfHealingCurrentStat = null

  eventPlayer.roundHackedElims = eventPlayer.currentHackedElims
  eventPlayer.currentHackedElims = null
  eventPlayer.roundMeleeFinalBlows = eventPlayer.currentMeleeFinalBlows
  eventPlayer.currentMeleeFinalBlows = null
  eventPlayer.roundCriticalFinalBlows = eventPlayer.currentCriticalFinalBlows
  eventPlayer.currentCriticalFinalBlows = null

  eventPlayer.roundRevivesStat = eventPlayer.currentRevivesStat
  eventPlayer.currentRevivesStat = null

  eventPlayer.earnMoney(
    eventPlayer.roundTeamEliminatedBots * MONEY_FOR_ELIMINATIONS_TEAM
    + eventPlayer.roundDamageDealtStat * MONEY_FOR_DAMAGE_DEALT
    + eventPlayer.roundDamageBlockedStat * MONEY_FOR_DAMAGE_BLOCKED
    + eventPlayer.roundDamageTakenStat * MONEY_FOR_DAMAGE_TAKEN
    + eventPlayer.roundOffensiveAssistsStat * MONEY_FOR_OFFENSIVE_ASSISTS
    + eventPlayer.roundDefensiveAssistsStat * MONEY_FOR_DEFENSIVE_ASSISTS
    + eventPlayer.roundRevivesStat * MONEY_FOR_REVIVE
    + (MONEY_FOR_ZERO_DEATHS if eventPlayer.roundDeathsStat == 0 else 0)
  )

  showPlayerStatsTime = getTotalTimeElapsed() + SHOW_ROUND_STATS_DURATION