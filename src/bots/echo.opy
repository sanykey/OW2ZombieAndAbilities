#!mainFile "../main.opy"

def botEchoFlyToPlayer():
  @Name "[ZombieTeam Echo] Fly to player"
  
  eventPlayer.startFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()), 300
  )
  eventPlayer.startThrottleInDirection(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()), 1, Relativity.TO_WORLD
  )
  eventPlayer.stopForcingButton(Button.JUMP)

def botEchoDetachPlayer():
  @Name "[ZombieTeam Echo] Detach player"
  
  eventPlayer.targetPlayer1.detach()
  eventPlayer.targetPlayer1.clearStatusEffect(Status.HACKED)

  #IF PLAYER INSIDE THE WALL
  if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.targetPlayer1.getEyePosition()):
    eventPlayer.targetPlayer1.teleport(eventPlayer.getPosition())

  eventPlayer.abilState0 = false
  eventPlayer.abilState1[eventPlayer.targetPlayer1.getSlot()] = getTotalTimeElapsed() + 5
  eventPlayer.targetPlayer1 = null
  

def botEchoRespawn():
  @Name "SUBROUTINE: ECHO - RESPAWN"
  eventPlayer.abilState1 = 0

  playEffect(getAllPlayers(), DynamicEffect.SOMBRA_EMP_EXPLOSION_EFFECT, Color.SKY_BLUE, eventPlayer.abilPos0, 12)
  playEffect(getAllPlayers(), DynamicEffect.SOMBRA_EMP_EXPLOSION_SOUND, null, eventPlayer.abilPos0, 100)
  wait(4)
  eventPlayer.teleport(eventPlayer.abilPos0)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.WHITE, eventPlayer.abilPos0, 2.5)
  playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.abilPos0, 100)


rule "[ZombieTeam Echo] Fly ability":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition not eventPlayer.isUsingAbility1()
  
  eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  wait(0.3)
  if ruleCondition:
    loop()

rule "[ZombieTeam Echo] Beam ability":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition not eventPlayer.isUsingAbility2()
  @Condition eventPlayer.abilState0
  
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
  eventPlayer.forceButtonPress(Button.ABILITY_2)


rule "[ZombieTeam Echo] respawn":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()

  eventPlayer.list0 = (
    [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  )

  if eventPlayer.list0:
    eventPlayer.abilPos0 = eventPlayer.list0[random.randint(0, len(eventPlayer.list0) - 1)]
    botEchoRespawn()

  wait(15, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[ZombieTeam Echo] can see player":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition eventPlayer.target0
  @Condition not eventPlayer.abilState0
  @Condition isInLoS(
    eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()
  )
  @Condition eventPlayer.abilState1[eventPlayer.target0.getSlot()] < getTotalTimeElapsed()
  
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()), 300)
  eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()), 1, Relativity.TO_WORLD)
  eventPlayer.stopForcingButton(Button.JUMP)


rule "[ZombieTeam Echo] Attach player by beam":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition eventPlayer.target0
  @Condition not eventPlayer.hasBadStatus
  @Condition not eventPlayer.targetPlayer1
  @Condition not eventPlayer.abilState0
  @Condition isInLoS(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()) == true
  @Condition distance(eventPlayer.getPosition(), eventPlayer.target0.getPosition()) < 3
  @Condition eventPlayer.abilState1[eventPlayer.target0.getSlot()] < getTotalTimeElapsed()
  
  eventPlayer.abilState0 = true
  eventPlayer.targetPlayer1 = eventPlayer.target0
  eventPlayer.targetPlayer1.setStatusEffect(eventPlayer, Status.STUNNED, 0.7)
  eventPlayer.targetPlayer1.setStatusEffect(eventPlayer, Status.HACKED, 10)
  eventPlayer.targetPlayer1.attachTo(eventPlayer, vect(0, 0, 1))
  eventPlayer.forceButtonPress(Button.ABILITY_2)

rule "[ZombieTeam Echo] Bad status - reset beam":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition eventPlayer.hasBadStatus
  
  if eventPlayer.abilState0:
    botEchoDetachPlayer()


rule "[ZombieTeam Echo] player dead":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition eventPlayer.targetPlayer1.isDead() != null
  
  if eventPlayer.abilState0:
    botEchoDetachPlayer()

rule "[ZombieTeam Echo] death":
  @Event playerDied
  @Team 2
  @Hero echo
  
  botEchoDetachPlayer()
  eventPlayer.stopForcingButton(Button.JUMP)

rule "[ZombieTeam Echo] main logic loop":
  @Event eachPlayer
  @Team 2
  @Hero echo
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()

  if not eventPlayer.targetPlayer1:
    goto lbl_0
  

  if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.targetPlayer1.getEyePosition()):
    botEchoDetachPlayer()

  eventPlayer.tmp0 = (
    sorted(
      [player for player in getLivingPlayers(Team.ZOMBIES).exclude(eventPlayer) if (
        player.hasSpawned() and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition())
      )],
      lambda i: distance(eventPlayer, i)
    )
  )[0]

  if eventPlayer.tmp0:
    eventPlayer.stopForcingButton(Button.JUMP)
    
    if distance(eventPlayer, eventPlayer.tmp0) < 3:
      eventPlayer.stopThrottleInDirection()
      eventPlayer.stopFacing()
      eventPlayer.setStatusEffect(null, Status.ROOTED, 0.5)
    else:
      eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tmp0.getEyePosition() + Vector.UP), 100)
      eventPlayer.startThrottleInDirection(
        directionTowards(eventPlayer.getEyePosition(), eventPlayer.tmp0.getEyePosition() + Vector.UP * 1), 1, Relativity.TO_WORLD
      )
  else:
    eventPlayer.startForcingButton(Button.JUMP)
    eventPlayer.stopThrottleInDirection()

  lbl_0:
  wait(0.4)
  if ruleCondition:
    loop()
