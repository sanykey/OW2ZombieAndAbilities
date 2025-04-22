#!mainFile "main.opy"

def disablePlayer():
  @Name "Subroutine: Disable Player"
  
  eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)
  eventPlayer.setPrimaryFireEnabled(false)
  eventPlayer.setSecondaryFireEnabled(false)
  eventPlayer.setAbility1Enabled(false)
  eventPlayer.setAbility2Enabled(false)
  eventPlayer.setMeleeEnabled(false)
  eventPlayer.setJumpEnabled(false)
  eventPlayer.setCrouchEnabled(false)
  eventPlayer.disallowButton(Button.ULTIMATE)

def enablePlayer():
  @Name "Subroutine: Enable Player"
  
  eventPlayer.stopForcingThrottle()
  eventPlayer.setPrimaryFireEnabled(true)
  eventPlayer.setSecondaryFireEnabled(true)
  eventPlayer.setAbility1Enabled(true)
  eventPlayer.setAbility2Enabled(true)
  eventPlayer.setMeleeEnabled(true)
  eventPlayer.setJumpEnabled(true)
  eventPlayer.setCrouchEnabled(true)
  eventPlayer.allowButton(Button.ULTIMATE)


rule "Team 1 (Death): Start Camera, Set is Downed, Revive Timer, Knocked down, Death Cam target":
  @Event playerDied
  @Team 1

  
  if not eventPlayer.downedStartTime:
    eventPlayer.disableMessages()
    pause3PCamera()
    smallMessage(getAllPlayers(), "{0} was downed!".format(eventPlayer))
    # eventPlayer.deathCamTarget = eventPlayer.getEyePosition() + 1000 * directionFromAngles(eventPlayer.getHorizontalFacingAngle(), 0)
    # eventPlayer.startCamera((raycast(eventPlayer.spectated_player.getEyePosition(), eventPlayer.spectated_player.getEyePosition() - (6.25 * directionTowards(eventPlayer.spectated_player.getEyePosition(), eventPlayer.deathCamTarget) if eventPlayer.deathCamTarget else 8.25 * directionFromAngles(eventPlayer.spectated_player.getHorizontalFacingAngle(), 20)), null, null, false).getHitPosition()) + (0.25 * (directionTowards(eventPlayer.spectated_player.getEyePosition(), eventPlayer.deathCamTarget) if eventPlayer.deathCamTarget else directionFromAngles(eventPlayer.spectated_player.getHorizontalFacingAngle(), 20))), eventPlayer.spectated_player.getEyePosition(), 10 if eventPlayer.deathCamTarget else 20)
    eventPlayer.downedStartTime = getTotalTimeElapsed()
    eventPlayer.reviveTimer = 0
    disablePlayer()
    
  if eventWasEnvironment:
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer))

  eventPlayer.resurrect()
  eventPlayer.clearStatusEffect(Status.PHASED_OUT)
  eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INFINITE)
  eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, INFINITE)
  wait(0.05, Wait.RESTART_WHEN_TRUE)
  eventPlayer.setHealth(1)
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, INFINITE)

rule "Revive, check player in radius, unset is downed":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.downedStartTime == true
  @Condition eventPlayer.downedStartTime + 1 < getTotalTimeElapsed()
  
  eventPlayer.revivers = [player for player in combatants if not player.downedStartTime and distance(eventPlayer, vect(player.getPosition().x, eventPlayer.getPosition().y, player.getPosition().z)) <= 3 and abs(eventPlayer.getPosition().y - player.getPosition().y) <= 3 and isInLoS(eventPlayer, player)]
  if eventPlayer.revivers == []:
      eventPlayer.reviveTimer = 0
  else:
      eventPlayer.reviveTimer += REVIVE_TIMER_TICK
      if eventPlayer.reviveTimer >= 100:
          smallMessage(getAllPlayers(), "{0} has been revived!".format(eventPlayer))
          eventPlayer.downedStartTime = 0
  wait(0.2)
  if ruleCondition:
      loop()


rule "Team 1: Player gets up":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.downedStartTime == false
  
  if not eventPlayer.isCombatant:
      return
  eventPlayer.enableMessages()
  eventPlayer.stopCamera()
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 200)
  eventPlayer.setHealth(INFINITE)
  # eventPlayer.spectated_player = eventPlayer
  eventPlayer.revivers = []
  eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
  eventPlayer.clearStatusEffect(Status.INVINCIBLE)
  enablePlayer()
  unpause3PCamera()
  wait(2.5, Wait.ABORT_WHEN_FALSE)
  if not ruleCondition:
      return
  eventPlayer.clearStatusEffect(Status.PHASED_OUT)
  if eventPlayer.getSlot() < ALLY_BOT_PLAYER_SLOT:
      return
  eventPlayer.communicate(Comms.READY)




# rule "Select next spectated Player when event player is downed":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.downedStartTime == true
#   @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
  
#   if eventPlayer.downedStartTime + 0.5 >= getTotalTimeElapsed():
#       return
#   eventPlayer.deathCamTarget = null
#   eventPlayer.spectated_player = combatants[(combatants.index(eventPlayer.spectated_player) + 1) % combatants_count]
#   wait(0.25)


# rule "Spectated player does not exist anymore. Set spectated player = event player":
#     @Event eachPlayer
#     @Team 1
#     @Condition eventPlayer.downedStartTime == true
#     @Condition eventPlayer.spectated_player.is_combatant == false
#     @Condition eventPlayer.spectated_player.getTeam() != Team.2
    
#     eventPlayer.spectated_player = eventPlayer