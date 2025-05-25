#!mainFile "../main.opy"

#!define BOT_WIDOWMAKER_RESPAWN_COOLDOWN 15
#!define BOT_ECHO_RESPAWN_COOLDOWN 15

def playEffectsForZombieTeleport():
  playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_2, eventPlayer.getEyePosition(), 1)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Team.1, eventPlayer.getEyePosition(), 200)

def teleportBotToHisHome():
  # playEffectsForZombieTeleport()
  eventPlayer.teleport(vectList[VL_ZOMBIE_BOT_HOME])

def GenjiResetShiftStrikeCooldown():
  @Name "[Genji] Reset Shift strike cooldown"
  wait(0.25)
  eventPlayer.list0.setAbilityCooldown(Button.ABILITY_1, 0)
  

# [Bot fake death] I accidentally discovered that if preventing bots from being killed and just teleporting them to respawn - it makes the server noticeably more stable
def botFakeDeathHandle():
  @Name "[Bot fake death] handle"

  eventPlayer.downedStartTime = true
  eventPlayer.isZombieReadyToRespawn = false
  # destroyIcon(eventPlayer.lastZombieIcon)
  # eventPlayer.lastZombieIcon = false

  # [Team2 Widowmaker] died
  if eventPlayer.getHero() == Hero.WIDOWMAKER:
    botWidowmakerClear()
    botWidowmakerRespawnTime = getTotalTimeElapsed() + BOT_WIDOWMAKER_RESPAWN_COOLDOWN
  # [Team2 Echo] died:
  elif eventPlayer.getHero() == Hero.ECHO:
    botEchoDetachPlayer()
    botEchoRespawnTime = getTotalTimeElapsed() + BOT_ECHO_RESPAWN_COOLDOWN
  # [Team2 Mauga] died:
  elif eventPlayer.getHero() == Hero.MAUGA and eventPlayer.isUsingAbility1():
    eventPlayer.stopThrottleInDirection()
    eventPlayer.stopFacing()
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.05)

  if isBotsDisabled == false:
    roundRemainingBots -= 1

  eventPlayer.setUltCharge(0)
  # reset the information about applying croud control abilities to the bot
  eventPlayer.lastCcAttacker = false
  eventPlayer.lastCcAttackTime = false
  eventPlayer.lastCcWasInAir = false

  # money, effects and team score for kills:
  eventPlayer.list0 = [player for player in getPlayers(Team.1) if eventPlayer.damageAssitsToSlot[player.getSlot()] > getTotalTimeElapsed()]
  smallMessage(eventPlayer.list0, "<TX C00000000021569> +${}".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list0.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list0.kills += 1
  eventPlayer.list0.lastKillTime = getTotalTimeElapsed()

  # [Genji] Reset Shift strike cooldown for native behavior since bots no longer die
  eventPlayer.list0 = [player for player in eventPlayer.list0 if player.getHero() == Hero.GENJI]
  if eventPlayer.list0:
    async(GenjiResetShiftStrikeCooldown, AsyncBehavior.NOOP)

  teamScore += MONEY_FOR_ZOMBIE_KILL

  eventPlayer.stopAllDamageOverTime()

  # wait 1 second for: 
  # - turrets damage detect
  # - Set the zombie's Status.KNOCKED_DOWN to make it look like it was killed
  eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, INFINITY)
  wait()
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, INFINITY) # Resetting continuing damage effects and disable the ability to interact with the "dead" bot.
  wait()
  heal(eventPlayer, null, 2) # heal for detect dot damage

  # After using some abilities against zombies, Status.KNOCKED_DOWN status may be reset - restore this status
  wait(0.45)
  if not eventPlayer.hasStatus(Status.KNOCKED_DOWN):
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    wait()
    eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, INFINITY)
    wait()
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, INFINITY) # Resetting continuing damage effects and disable the ability to interact with the "dead" bot.
    wait()
    heal(eventPlayer, null, 2) # heal for detect dot damage
  wait(0.6)

  # Turret damage has to be counted with a delay, so it is counted separately from other types of damage
  eventPlayer.list0 = [player for player in getPlayers(Team.1) if (
    eventPlayer.turretDamageTimeToSlot[player.getSlot()] >= getTotalTimeElapsed() and
    eventPlayer.damageAssitsToSlot[player.getSlot()] < getTotalTimeElapsed()
  )]
  smallMessage(eventPlayer.list0, "<TX C00000000003389> +${}".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list0.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list0.kills += 1
  eventPlayer.damageAssitsToSlot = []
  eventPlayer.turretDamageTimeToSlot = []

  eventPlayer.isZombieReadyToRespawn = true


# Bots shouldn't die (Bot fake death), but just in case, let's keep an eye on the event
rule "[Bot fake death] Bot died":
  @Event playerDied
  @Team 2
  botFakeDeathHandle()

rule "[Bot fake death] low hp = die (for turrets)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHealth() < BOT_FAKE_DIE_HP_THRESHOLD
  @Condition eventPlayer.isReady
  @Condition not eventPlayer.downedStartTime

  if not eventPlayer.downedStartTime:
  botFakeDeathHandle()



rule "fix broken immortal bots":
  @Event eachPlayer
  @Team 2
  @Condition roundNumber > 0

  if (
    eventPlayer.downedStartTime or
    not eventPlayer.isAlive() or
    eventPlayer.getHealth() > BOT_FAKE_DIE_HP_THRESHOLD or
    not eventPlayer.isReady
  ):
    goto lbl_0

  waitUntil(eventPlayer.downedStartTime == true, 0.5)
  if not eventPlayer.downedStartTime:
    eventPlayer.clearStatusEffect(Status.UNKILLABLE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
    smallMessage(hostPlayer, "[Server]: Immortal zombie found. Trying not to neutralize immortality")

  lbl_0:
  wait(3, Wait.ABORT_WHEN_FALSE)
  loop()

# rule "[Bot fake death] Trigger bot respawn after round start":
#   @Event eachPlayer
#   @Team 2
#   @Condition roundRemainingBots > 0

#   if eventPlayer.downedStartTime:
#     botFakeDeathRespawn()

# rule "[debug] lastKillTime":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0

#   debug(floor((getTotalTimeElapsed() - floor(getTotalTimeElapsed())) * 100) % (wSettingsMaxZombieBots) * 2)


# rule "[Bot fake death] Create bots death place icons and last zombies icons":
#   botsDeathPlaceIcons = []
#   # Create bots death place icons
#   for I in range(wSettingsMaxZombieBots):
#     botsDeathPlaceIcons[I] = hiddenVector
#     createInWorldText(
#       getPlayers(Team.1),
#       "<TX C0000000000B667>", # <TX C0000000000B666> <TX C0000000001C365> <TX C0000000002178B>
#       botsDeathPlaceIcons[evalOnce(I)],
#       10,
#       Clip.SURFACES,
#       WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
#       color=rgb(false,false,false,95)
#     )


# rule "Create icons for last zombies":
#   @Condition roundNumber > 0

#   if roundRemainingBots > 0 and LAST_ZOMBIES_ICONS_AMOUNT >= roundRemainingBots:
#     lastZombiesList = [player for player in getLivingPlayers(Team.2) if not player.downedStartTime]
#     for lastZombiesI in range(len(lastZombiesList)):
#       if not lastZombiesList[lastZombiesI].lastZombieIcon:
#         createIcon(getPlayers(Team.1), evalOnce(lastZombiesList[lastZombiesI]), Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
#         lastZombiesList[lastZombiesI].lastZombieIcon = getLastCreatedEntity()
#         lastZombiesIcons[lastZombiesI] = getLastCreatedEntity() # Save here the IDs of created icons, so that you can delete icons in case Dummy bots will be deleted.

#   wait(3)
#   loop()