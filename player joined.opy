#!mainFile "main.opy"

rule "Starting Spawn Location for players":
  @Event eachPlayer
  @Team 1
  @Hero dva
  @Condition eventPlayer.isInSpawnRoom() == true
  
  eventPlayer.startCamera(vect(-17.532, 3.356, -16.72), vect(-26.463, -0.316, -14.143))
  eventPlayer.teleport(vect(-27.412, 8.678, -12.564))
  eventPlayer.disableGamemodeHud()
  eventPlayer.disableHeroHud()
  wait(0.3)
  eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
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


rule "Late Joiner Catchup [15]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 15
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 25000
  eventPlayer.health_stat += 200
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
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

rule "Late Joiner Catchup [25]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 25
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 75000
  eventPlayer.health_stat += 500
  eventPlayer.setMaxHealth(eventPlayer.health_stat)


rule "Late Joiner Catchup [50]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 50
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 50000
  eventPlayer.health_stat += 1250
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  wait(1.5)
  heal(eventPlayer, null, 99999)

rule "Team Shields and Armor for Joiner":
  @Event playerJoined
  @Team 1

  eventPlayer.stateArr[stateI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.addHealthPool(Health.SHIELDS, team_shields, true)
  eventPlayer.addHealthPool(Health.ARMOR, team_armor, true)