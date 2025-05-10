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

# rule "Mercy: revive ability (player)":
#   @Event eachPlayer
#   @Team 1
#   @Hero mercy
#   @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
#   @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
#   #Workaround: Check Cooldown for Controller Players
#   @Condition eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) == 0
#   @Condition eventPlayer.downedStartTime == false
#   @Condition eventPlayer.hasStatus(Status.HACKED) == false
#   @Condition eventPlayer.hasStatus(Status.STUNNED) == false
  
#   eventPlayer.targetPlayer = (sorted([player for player in getPlayersInRadius(eventPlayer, 8, Team.1) if player.downedStartTime and player.downedStartTime + 0.1 < getTotalTimeElapsed() and eventPlayer.isInViewAngle(player, 45)], lambda i: dotProduct(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), i)))).last()
#   if eventPlayer.targetPlayer:
#     smallMessage(getAllPlayers(), "{0} has been resurrected by {1}!".format(eventPlayer.targetPlayer, eventPlayer))
#     eventPlayer.targetPlayer.downedStartTime = 0
#     playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.SKY_BLUE, eventPlayer.targetPlayer, 1)
#     eventPlayer.setAbilityCooldown(Button.ABILITY_2, 30)
#     #Workaround: Set Cooldown for Controller Players
#     eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 30)
#   wait(0.05)