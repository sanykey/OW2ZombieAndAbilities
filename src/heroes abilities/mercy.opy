#!mainFile "../main.opy"



rule "[Mercy] Immune during revive":
  @Event eachPlayer
  @Team 1
  @Hero mercy
  @Condition eventPlayer.isUsingAbility2() == true
  
  eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 4)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.YELLOW, eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.YELLOW, eventPlayer, 5)
  smallMessage(eventPlayer, "Temporarily Immune (4s) during revive")
  wait(1.7)
  if not RULE_CONDITION:
      return
  getPlayersInRadius(eventPlayer, 10, Team.2).setStatusEffect(null, Status.STUNNED, 4)

rule "Mercy: revive":
  @Event eachPlayer
  @Team 1
  @Hero mercy
  @Condition eventPlayer.isUsingAbility2()
  
  eventPlayer.targetPlayer0 = (
    sorted([
      player for player in getPlayersInRadius(eventPlayer, 8, Team.1) if player.isDead() and eventPlayer.isInViewAngle(player, 45)
    ], 
    lambda i: dotProduct(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), i)))
  ).last()

  if not eventPlayer.targetPlayer0:
    return

  waitUntil(not eventPlayer.isUsingAbility2(), 2)

  if eventPlayer.targetPlayer0.isAlive():
    eventPlayer.targetPlayer0.downedStartTime = 0
    eventPlayer.currentRevivesStat += 1

rule "Mercy: revive":
  @Event eachPlayer
  @Team 1
  @Hero mercy

  debug(eventPlayer.isUsingAbility2())
  debug(eventPlayer.targetPlayer0)
  debug(eventPlayer.currentRevivesStat)