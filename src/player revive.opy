#!mainFile "main.opy"

#!define RIVIVE_RADIUS 3
#!define REVIVE_TIMER_TICK 5

rule "[Revive] Init huds":
  # revive hud
  hudSubtext(
    getDeadPlayers(Team.1),
    "Wait until your teammates revive you, or 120 seconds pass, or the round ends.",
    HudPosition.TOP,
    -70,
    Color.YELLOW,
    HudReeval.VISIBILITY_AND_STRING
  )

  # revive progress bar
  progressBarHud(
    localPlayer if (localPlayer.reviveTimer if localPlayer.isDead() else any([localPlayer in player.revivers for player in getPlayers(Team.1)])) else [],
    localPlayer.reviveTimer if localPlayer.isDead() else ((sorted([player for player in getPlayers(Team.1) if localPlayer in player.revivers], lambda i: i.reviveTimer)).last()).reviveTimer,
    "You are being revived" if localPlayer.isDead() else "Reviving {0}".format("{0} Teammates".format(len([player for player in getPlayers(Team.1) if localPlayer in player.revivers])) if len([player for player in getPlayers(Team.1) if localPlayer in player.revivers]) > 1 else ([player for player in getPlayers(Team.1) if localPlayer in player.revivers])[0]),
    HudPosition.TOP,
    100,
    Color.SKY_BLUE
  )

rule "[Revive] player died":
  @Event playerDied
  @Team 1

  UpdateCombatantsSub()
  eventPlayer.isReady = true

  pause3PCamera()
  smallMessage(getAllPlayers(), "{0} was downed!".format(eventPlayer))
  eventPlayer.reviveTimer = false
  eventPlayer.teleport(nearestWalkablePosition(eventPlayer))

  # create reviving circle effect
  createEffect(getPlayers(Team.1), Effect.RING, Color.YELLOW, eventPlayer, RIVIVE_RADIUS, EffectReeval.NONE)
  eventPlayer.effectsIds[REVIVE_CIRCLE_EFFECT] = getLastCreatedEntity()

  createInWorldText(
    getPlayers(Team.1),
    "{} {}".format(heroIcon(eventPlayer.getHero()), eventPlayer),
    vect(eventPlayer.getPosition().x, eventPlayer.getPosition().y + 1.7, eventPlayer.getPosition().z),
    1,
    Clip.NONE,
    WorldTextReeval.NONE,
    Color.YELLOW
  )
  eventPlayer.effectsIds[REVIVE_TEXT] = getLastCreatedText()

rule "[Revive] Check player in radius, unset is downed":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isDead()
  
  eventPlayer.revivers = [
    player for player in combatants if (
      player.isAlive() and distance(eventPlayer, player) <= RIVIVE_RADIUS 
    )
  ]
  if not eventPlayer.revivers:
    eventPlayer.reviveTimer = false
  else:
    eventPlayer.reviveTimer += REVIVE_TIMER_TICK
    if eventPlayer.reviveTimer >= 100:
      smallMessage(getAllPlayers(), "{0} has been revived!".format(eventPlayer))
      IncrementReviveStatSub()
      eventPlayer.resurrect()
  
  wait(0.3, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()


rule "[Revive] Player gets up":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive()
  
  UpdateCombatantsSub()
  destroyEffect(eventPlayer.effectsIds[REVIVE_CIRCLE_EFFECT])
  destroyInWorldText(eventPlayer.effectsIds[REVIVE_TEXT])
  eventPlayer.revivers = false
  eventPlayer.reviveTimer = false
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 200)
  eventPlayer.setHealth(INFINITY)
  unpause3PCamera()
