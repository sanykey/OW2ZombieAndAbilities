#!mainFile "../main.opy"

# rule "[Mercy] init":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.getHero() == Hero.MERCY

#   setHeroInfoText0(
#     "
#     {} <fgece9bdFF>Mercy</fg>:\n
#     {} <fgece9bdFF>Endothermic blaster</fg>
#       - While in the air, slightly pushes Mei in the opposite direction of the shot.\n\n
#     {} <fgece9bdFF>Cryo-freeze</fg>:
#       - instantly freeze nearby enemies once cryo-freeze breaks.\n\n
#     - All heroes deal double damage to frozen enemies.
#     ".format(
#       heroIcon(Hero.MERCY),
#       abilityIconString(Hero.MERCY, Button.PRIMARY_FIRE),
#       abilityIconString(Hero.MERCY, Button.ABILITY_1)
#     )
#   )
  
#   waitUntil(eventPlayer.getHero() != Hero.MERCY, INFINITY)
#   clearHeroInfo()


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
  getPlayersInRadius(eventPlayer, 5, Team.2).setStatusEffect(null, Status.STUNNED, 2)

rule "[Mercy] revive":
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


# rule "[Mercy]: start pocketing":
#   @Event eachPlayer
#   @Team 1
#   @Hero mercy
#   @Condition eventPlayer.isFiringSecondaryFire()
#   @Condition not eventPlayer.targetPlayer1
#   @Condition (
#     eventPlayer.isInViewAngle(
#       eventPlayer.getPlayerClosestToReticle(eventPlayer.getTeam()) in [player form player in getPlayersInRadius(eventPlayer, 15.8) if player.isAlive() and player.isAlive()]
#       , 23.2)
#   )
#   @Condition distance(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.1)) < 15.8

#   (eventPlayer.getPlayerClosestToReticle(eventPlayer.getTeam()) in ([player for player in (getPlayersInRadius(eventPlayer, 30 if not eventPlayer.isUsingUltimate() else 60, eventPlayer.getTeam(), LosCheck.SURFACES)) if eventPlayer.isInViewAngle(player, 10) and player.isAlive() and not player.isDummy() and player != eventPlayer and eventPlayer.mercy_bot[1] != player])) else ([player for player in (getPlayersInRadius(eventPlayer, 30 if not eventPlayer.isUsingUltimate() else 60, eventPlayer.getTeam(), LosCheck.SURFACES)) if eventPlayer.isInViewAngle(player, 10) and player.isAlive() and not player.isDummy() and player != eventPlayer and eventPlayer.mercy_bot[1] != player])[0]




#   eventPlayer.targetPlayer1 = eventPlayer.getRealPlayerClosestToReticle(Team.1)

# rule "[Mercy] Stop pocketing":
#   @Event eachPlayer
#   @Team 1
#   @Hero mercy
#   @Condition eventPlayer.targetPlayer1
#   @Condition (
#     not eventPlayer.isFiringSecondaryFire() or 
#     eventPlayer.isReloading() or
#     not isInLoS(eventPlayer, eventPlayer.targetPlayer1, BarrierLos.PASS_THROUGH_BARRIERS) or
#     distance(eventPlayer, eventPlayer.getRealPlayerClosestToReticle(Team.1)) >= 15.8
#   )

#   if not eventPlayer.isFiringSecondaryFire() or eventPlayer.isReloading():
#     eventPlayer.targetPlayer1 = null
  
#   waitUntil(not ruleCondition, 1.25)
#   if not ruleCondition:
#     return
#   eventPlayer.targetPlayer1 = null

# rule "[Mercy]: debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero mercy

#   debug(eventPlayer.isFiringSecondaryFire())
#   debug(eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(Team.1), 23.2))
#   debug(distance(hostPlayer, getPlayersInSlot(ALLY_BOT_PLAYER_SLOT, Team.1)))
#   debug(eventPlayer.isReloading())
#   debug(eventPlayer.targetPlayer1)