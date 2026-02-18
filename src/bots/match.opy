#!mainFile "../main.opy"

#!define ROUND_START_DELAY 7
#!define MAX_REMAINING_ZOMBIES_IN_ROUND 80

rule "Init delayed start header":
  # delayed start
  hudHeader(
    localPlayer if not localPlayer.isHeroDescriptionOpened else null,
    "\n\u2001{0}\n\n\u2001Hold {1} to Start\u2001\n".format(
      "Zombie survival", inputBindingString(Button.INTERACT)
    ), 
    HudPosition.TOP,
    1,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )
  delayerStartHudId = getLastCreatedText()


def MatchStartSub():
  @Name "Sub: match start"
  smallMessage(getAllPlayers(), "Match begins!")
  destroyHudText(delayerStartHudId)
  isGameStarted = true

rule "Waiting for players ready":
  @Event eachPlayer
  @Team 1
  @Condition not isGameStarted
  @Condition not debugMenuIsOpened
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.CROUCH) 

  wait(0.5, Wait.ABORT_WHEN_FALSE)
  MatchStartSub()

def ReviveAllPlayersSub():
  @Name "Sub: revive all players"
  [player for player in getPlayers(Team.1) if player.isDead()].resurrect()
  UpdateCombatantsSub()

rule "Match end":
  @Condition isGameStarted
  @Condition getNumberOfPlayers() > 1
  @Condition all(
    [player.isDead() or (not player.hasSpawned() and not player.posBeforeChangeHero) for player in getPlayers(Team.1)]
  )
  
  matchIsOver = true
  destroyAllEffects()
  destroyAllInWorldTexts()
  wait(3)
  bigMessage(getAllPlayers(), "Survived {} rounds".format(roundNumber))
  bigMessage(getAllPlayers(), "Total Score: {}".format(teamScore))
  wait(4)
  declareTeamVictory(Team.ZOMBIES)
  wait(1.5)
  restartMatch()

rule "Unlimited match time":
  @Condition getMatchTime() < 10
  @Condition matchIsOver == false
  setMatchTime(3599)

rule "Round start":
  @Condition isGameStarted
  @Condition roundRemainingBots <= 0
  @Condition not matchIsOver
  @Condition not isBotsDisabled
  
  roundNumber += 1
  
  bigMessage(getAllPlayers(), "Round {}".format(roundNumber))
  setObjectiveDescription(localPlayer, "Round {}, Team score: {}".format(roundNumber, teamScore), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  
  ReviveAllPlayersSub()

  zomSpeedPct = ZOMBIE_BASE_SPEED + roundNumber * 0.25
  if zomSpeedPct > ZOMBIE_MAX_SPEED_PCT:
    zomSpeedPct = ZOMBIE_MAX_SPEED_PCT

  zomMaxHealthPct = (
    ZOMBIE_BASE_HP + 10 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)))
  )
  zomDamagePct = (
    ZOMBIE_BASE_DAMAGE + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)))
  )

  getPlayers(Team.ZOMBIES).setMoveSpeed(zomSpeedPct)
  getPlayers(Team.ZOMBIES).setMaxHealth(zomMaxHealthPct)
  getPlayers(Team.ZOMBIES).setDamageDealt(zomDamagePct)
 
  if roundNumber > 1: # No delay needed before the first round
    wait(ROUND_START_DELAY)
  
  bigMessage(getPlayers(Team.1), "Starting Round!")
  # wait() # At the start of the round, bots spawn with incomplete health after the max health buff. This respawn delay is an attmpt to fix that
  # # As soon as the "roundRemainingBots" is greater than 0 they will start respawning again
  # roundRemainingBots = (
  #   wSettingsMaxZombieBots + roundNumber if (wSettingsMaxZombieBots + roundNumber) < MAX_REMAINING_ZOMBIES_IN_ROUND else MAX_REMAINING_ZOMBIES_IN_ROUND
  # )

  roundRemainingBots = wSettingsMaxZombieBots + roundNumber
  roundMaxBots = roundRemainingBots

