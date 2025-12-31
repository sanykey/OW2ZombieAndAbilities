#!mainFile "main.opy"
globalvar roundStatsHudId

#!define MONEY_FOR_ZERO_DEATHS 1500
#!define SHOW_ROUND_STATS_DURATION 10
enum RoundStats:
  # calculating from getStatistic():
  ELIMINATIONS
  DAMAGE_DEALT
  DAMAGE_BLOCKED
  DAMAGE_TAKEN
  OFFENSIVE_ASSISTS
  DEFENSIVE_ASSISTS
  DEATHS
  # custom:
  CRITICAL_FINAL_BLOW
  MELEE_FINAL_BLOW
  HACKED_ELIMS
  HEALING
  SELF_HEALING
  REVIVES
  ELIMINATIONS_TEAM

globalvar rewardsList = compressed([
  120,  # ELIMINATIONS
  0.2,  # DAMAGE_DEALT
  0.1,  # DAMAGE_BLOCKED
  0.1,  # DAMAGE_TAKEN
  120,  # OFFENSIVE_ASSISTS
  120,  # DEFENSIVE_ASSISTS
  0,    # ZERO DEATHS
  75,   # CRITICAL_FINAL_BLOW
  75,   # MELEE_FINAL_BLOW
  75,   # HACKED_ELIMS
  0.6,  # HEALING
  0.3,  # SELF_HEALING
  500,  # REVIVES
  80    # ELIMINATIONS_TEAM
])
playervar roundStats
playervar prevRoundStats
playervar roundStatsText

def CalcRoundStatSub():
  @Name "Sub: Calc Round Stat"
  eventPlayer.roundStats[eventPlayer.tmp1] = eventPlayer.tmp2 - eventPlayer.prevRoundStats[eventPlayer.tmp1]
  eventPlayer.earnMoney(eventPlayer.roundStats[eventPlayer.tmp1] * rewardsList[eventPlayer.tmp1])
  eventPlayer.prevRoundStats[eventPlayer.tmp1] = eventPlayer.tmp2
  eventPlayer.tmp1++

def CalcRoundCustomStatSub():
  @Name "Sub: Calc Custom Round Stat"
  eventPlayer.roundStats[eventPlayer.tmp1] = eventPlayer.prevRoundStats[eventPlayer.tmp1]
  eventPlayer.earnMoney(eventPlayer.roundStats[eventPlayer.tmp1] * eventPlayer.tmp3)
  eventPlayer.prevRoundStats[eventPlayer.tmp1] = null

  eventPlayer.tmp1++

def IncrementReviveStatSub():
  eventPlayer.prevRoundStats[RoundStats.REVIVES] += 1

macro Player.addStat(self, type, amount):
  self.prevRoundStats[type] += amount

rule "Calculate player round stats":
  @Event eachPlayer
  @Team 1
  @Condition roundRemainingBots <= 0 and roundNumber > 1

  eventPlayer.roundStatsText = "\n\nRound statistics:"

  eventPlayer.tmp1 = false # reset the array iteration counter

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.ELIMINATIONS)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.DAMAGE_DEALT)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.DAMAGE_BLOCKED)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.DAMAGE_TAKEN)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS)
  CalcRoundStatSub()

  eventPlayer.tmp2 = eventPlayer.getStatistic(Stat.DEATHS)
  CalcRoundStatSub()
  eventPlayer.earnMoney(MONEY_FOR_ZERO_DEATHS if not eventPlayer.roundStats[RoundStats.DEATHS] else null)
  
  CalcRoundCustomStatSub() # CRITICAL_FINAL_BLOW
  
  CalcRoundCustomStatSub() # MELEE_FINAL_BLOW

  CalcRoundCustomStatSub() # HACKED_ELIMS

  CalcRoundCustomStatSub() # HEALING

  CalcRoundCustomStatSub() # SELF_HEALING

  CalcRoundCustomStatSub() # REVIVES

  eventPlayer.roundStats[eventPlayer.tmp1] = roundMaxBots # ELIMINATIONS_TEAM
  eventPlayer.earnMoney(roundMaxBots * rewardsList[eventPlayer.tmp1])

macro getStatText(text, type):
  "\n{}: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
    text, localPlayer.roundStats[type], localPlayer.roundStats[type] * rewardsList[type]
  ) if localPlayer.roundStats[type] else ""

rule "Init player round stats hud":
  @Condition roundRemainingBots <= 0 and roundNumber > 1
  destroyHudText(roundStatsHudId)
  wait(0.5)
  hudText(
    localPlayer if not localPlayer.isHeroDescriptionOpened and localPlayer.getTeam() == Team.1 else null,
    null,
    "\n\nRound <fgecbe52FF>{}</fg> statistics:{}{}{}{}{}{}{}{}{}{}{}{}{}{}".format(
      roundNumber - 1,
      getStatText("Eliminations",         RoundStats.ELIMINATIONS),
      getStatText("Damage dealt",         RoundStats.DAMAGE_DEALT),
      getStatText("Critical final blows", RoundStats.CRITICAL_FINAL_BLOW),
      getStatText("Melee final blows",    RoundStats.MELEE_FINAL_BLOW),
      getStatText("Hacked eliminations",  RoundStats.HACKED_ELIMS),
      getStatText("Offensive assists",    RoundStats.OFFENSIVE_ASSISTS),
      getStatText("Defensive assists",    RoundStats.DEFENSIVE_ASSISTS),
      "\nDeaths: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundStats[RoundStats.DEATHS], MONEY_FOR_ZERO_DEATHS if not localPlayer.roundStats[RoundStats.DEATHS] else 0
      ),
      getStatText("Revives",              RoundStats.REVIVES),
      getStatText("Healing",              RoundStats.HEALING),
      getStatText("Self healing",         RoundStats.SELF_HEALING),
      getStatText("Damage blocked",       RoundStats.DAMAGE_BLOCKED),
      getStatText("Damage taken",         RoundStats.DAMAGE_TAKEN),
      "\nRound bonus: <fg84c951FF>+${}</fg>".format(localPlayer.roundStats[RoundStats.ELIMINATIONS_TEAM] * rewardsList[RoundStats.ELIMINATIONS_TEAM])
    ),
    null,
    HudPosition.ACTUALLY_LEFT,
    10,
    null,
    Color.WHITE,
    null,
    HudReeval.VISIBILITY_AND_STRING
  )
  roundStatsHudId = getLastCreatedText()

  wait(SHOW_ROUND_STATS_DURATION)
  destroyHudText(roundStatsHudId)