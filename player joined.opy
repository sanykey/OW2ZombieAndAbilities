#!mainFile "main.opy"
def updateCombatants():
  @Name "Subroutine: Update Combatants"
  
  combatants = [player for player in getPlayers(Team.1) if player.isCombatant]
  combatantsCount = len(combatants)

rule "Create vips list":
  vips = ["snky"]
  

rule "Disable spawn room hero swap":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.hasSpawned() == true
  
  eventPlayer.isCombatant = true
  eventPlayer.disableRespawn()
  updateCombatants()

  if eventPlayer.healthStat == 0:
    eventPlayer.healthStat = 100
    eventPlayer.damageStat = 100
    eventPlayer.healingStat = 100

  # revive effects
  createEffect(getAllPlayers() if eventPlayer.downedStartTime else [], Effect.RING, Color.YELLOW, eventPlayer, 3, EffectReeval.VISIBILITY)
  createIcon(getAllPlayers().exclude(eventPlayer) if eventPlayer.downedStartTime else [], eventPlayer, Icon.SKULL, IconReeval.VISIBILITY, Color.YELLOW)

  eventPlayer.F = false
  eventPlayer.H = 1

  # Change character for vip players
  if "{0}".format(eventPlayer) in vips == true:
    wait(2)
    eventPlayer.startForcingHero(Hero.ASHE)
    eventPlayer.stateArr[0] = 4
    smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")


rule "Starting spawn location for players":
  @Event eachPlayer
  @Team 1
  @Hero dva
  @Condition eventPlayer.isInSpawnRoom() == true
  
  eventPlayer.startCamera(vect(-17.532, 3.356, -16.72), vect(-26.463, -0.316, -14.143))
  eventPlayer.teleport(vect(-27.412, 8.678, -12.564))
  eventPlayer.disableGamemodeHud()
  eventPlayer.disableHeroHud()
  wait(0.3)
  eventPlayer.setStatusEffect(null, Status.ROOTED, INFINITE)
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, INFINITE)
  eventPlayer.disallowButton(Button.PRIMARY_FIRE + Button.SECONDARY_FIRE + Button.ABILITY_1 + Button.ABILITY_2 + Button.ULTIMATE + Button.INTERACT + Button.JUMP + Button.CROUCH + Button.MELEE)
  eventPlayer.startFacing(Vector.RIGHT, 100000, Relativity.TO_PLAYER)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 2)
  wait(0.8)
  eventPlayer.setUltCharge(0)
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), vect(-12.858, 3.32, -17.254)), 100000)
  wait(0.1)
  eventPlayer.stopCamera()
  eventPlayer.stopFacing()
  eventPlayer.enableGamemodeHud()
  eventPlayer.enableHeroHud()
  getPlayers(Team.2).applyImpulse(Vector.UP, 2, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.5)
  eventPlayer.setMoveSpeed(100)
  eventPlayer.allowButton(Button.PRIMARY_FIRE + Button.SECONDARY_FIRE + Button.ABILITY_1 + Button.ABILITY_2 + Button.ULTIMATE + Button.INTERACT + Button.JUMP + Button.CROUCH + Button.MELEE + Button.RELOAD)
  eventPlayer.clearStatusEffect(Status.PHASED_OUT)
  eventPlayer.clearStatusEffect(Status.ROOTED)
  eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 5)
  eventPlayer.enablePlayerCollision()


rule "Late joiner catchup [15]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 15
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 25000
  eventPlayer.healthStat += 200
  eventPlayer.setMaxHealth(eventPlayer.healthStat)
  wait(0.064)
  heal(eventPlayer, null, 99999)
  eventPlayer.setDamageReceived(25)
  wait(10)
  smallMessage(eventPlayer, "Welcome! A Late Joiner Buff has been activated!")
  wait(5)
  smallMessage(eventPlayer, "Bonus Points, HP & Temp Damage Reduction (180s)")
  wait(180)
  eventPlayer.setDamageReceived(85)
  smallMessage(eventPlayer, "Your damage reduction buff has now ended. Good luck!")

rule "Late joiner catchup [25]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 25
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 75000
  eventPlayer.healthStat += 500
  eventPlayer.setMaxHealth(eventPlayer.healthStat)


rule "Late joiner catchup [50]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 50
  
  waitUntil(eventPlayer.hasSpawned(), INFINITE)
  eventPlayer.money += 50000
  eventPlayer.healthStat += 1250
  eventPlayer.setMaxHealth(eventPlayer.healthStat)
  wait(1.5)
  heal(eventPlayer, null, INFINITE)

rule "Team shields and armor for joiner":
  @Event playerJoined
  @Team 1

  eventPlayer.stateArr[stateI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY
  
  waitUntil(eventPlayer.hasSpawned(), INFINITE)
  eventPlayer.addHealthPool(Health.SHIELDS, team_shields, true)
  eventPlayer.addHealthPool(Health.ARMOR, team_armor, true)