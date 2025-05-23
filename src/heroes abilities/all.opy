#!mainFile "../main.opy"

#!define REI_BARRIER_PUSH_ENENT_WAIT 0.1

def sqrtNewton():
  @Name "Subroutine: Calculate square root"
  eventPlayer.raycast[RI.SQRT_RESULT] = eventPlayer.raycast[RI.DISC] / 2
  for eventPlayer.temp3 in range(5):
    eventPlayer.raycast[RI.SQRT_RESULT] = (eventPlayer.raycast[RI.SQRT_RESULT] + (eventPlayer.raycast[RI.DISC] / eventPlayer.raycast[RI.SQRT_RESULT])) / 2

def rayIntersectionsWithSphere():
  @Name "Subroutine: Сalculate the intersections of the ray with the sphere"

  eventPlayer.raycast[RI.RESULT] = false
  eventPlayer.raycast[RI.A] = (
    (eventPlayer.raycast[RI.FACING_DIRECTION].x * eventPlayer.raycast[RI.FACING_DIRECTION].x) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].y * eventPlayer.raycast[RI.FACING_DIRECTION].y) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].z * eventPlayer.raycast[RI.FACING_DIRECTION].z)
  )

  eventPlayer.raycast[RI.XPXS] = eventPlayer.getEyePosition().x - eventPlayer.raycast[RI.SPHERE_POS].x
  eventPlayer.raycast[RI.YPYS] = eventPlayer.getEyePosition().y - eventPlayer.raycast[RI.SPHERE_POS].y
  eventPlayer.raycast[RI.ZPYS] = eventPlayer.getEyePosition().z - eventPlayer.raycast[RI.SPHERE_POS].z

  eventPlayer.raycast[RI.B] = 2 * (
    (eventPlayer.raycast[RI.FACING_DIRECTION].x * eventPlayer.raycast[RI.XPXS]) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].y * eventPlayer.raycast[RI.YPYS]) + 
    (eventPlayer.raycast[RI.FACING_DIRECTION].z * eventPlayer.raycast[RI.ZPYS])
  )

  eventPlayer.raycast[RI.C] = (
    (eventPlayer.raycast[RI.XPXS] * eventPlayer.raycast[RI.XPXS]) +
    (eventPlayer.raycast[RI.YPYS] * eventPlayer.raycast[RI.YPYS]) +
    (eventPlayer.raycast[RI.ZPYS] * eventPlayer.raycast[RI.ZPYS]) -
    (eventPlayer.raycast[RI.RADIUS] * eventPlayer.raycast[RI.RADIUS])
  )

  eventPlayer.raycast[RI.DISC] = (eventPlayer.raycast[RI.B] * eventPlayer.raycast[RI.B]) - (4 * eventPlayer.raycast[RI.A] * eventPlayer.raycast[RI.C])

  if eventPlayer.raycast[RI.DISC] < 0:
    return
  
  sqrtNewton()

  eventPlayer.raycast[RI.T1] = ((eventPlayer.raycast[RI.B] * -1) - eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])
  eventPlayer.raycast[RI.T2] = ((eventPlayer.raycast[RI.B] * -1) + eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])

  eventPlayer.raycast[RI.C] = 0

  if (eventPlayer.raycast[RI.T1] >= 0 and eventPlayer.raycast[RI.T2] >= 0):
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T1] if eventPlayer.raycast[RI.T1] < eventPlayer.raycast[RI.T2] else eventPlayer.raycast[RI.T2]
  elif eventPlayer.raycast[RI.T1] >= 0:
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T1]
  elif eventPlayer.raycast[RI.T2] >= 0:
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T2]
  else:
    return

  eventPlayer.raycast[RI.RESULT] = vect(
    eventPlayer.getEyePosition().x + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].x,
    eventPlayer.getEyePosition().y + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].y,
    eventPlayer.getEyePosition().z + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].z
  )


rule "Chase abilityCD":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.abilityCD
  @SuppressWarnings w_ow2_rule_condition_chase
  
  chaseAtRate(eventPlayer.abilityCD, 0, 1)
  waitUntil(not eventPlayer.abilityCD, INFINITY)
  eventPlayer.abilityCD = false
  stopChasingVariable(eventPlayer.abilityCD)
  wait()
  if ruleCondition:
    loop()


macro Player.setRevealed(self, duration=REVEAL_DURATION):
  self.revealed = duration + getTotalTimeElapsed()

rule "Revealed zombies":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.revealed >= getTotalTimeElapsed()
  
  if eventPlayer.HUDs[HI.REVEALED_ICON] == false:
    createInWorldText(
      getAllPlayers(),
      "o",
      eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
      0.6,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
      Color.TEAM_2
    )
    eventPlayer.HUDs[HI.REVEALED_ICON] = getLastCreatedText()
  eventPlayer.startForcingOutlineFor(getAllPlayers(), true, Color.VIOLET, OutlineVisibility.OCCLUDED)

  waitUntil(eventPlayer.revealed < getTotalTimeElapsed() or eventPlayer.isAlive() == false, INFINITY)

  eventPlayer.revealed = false
  destroyInWorldText(eventPlayer.HUDs[HI.REVEALED_ICON])
  eventPlayer.HUDs[HI.REVEALED_ICON] = false
  eventPlayer.stopForcingOutlineFor(getAllPlayers())

rule "[Ramattra][Reinhardt][Sigma][Winston] Damage barrier":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]

  if eventPlayer.state[SI.BARRIER_DAMAGE_STACK]:
    createProjectile(
      Projectile.ORISA_FUSION_DRIVER, # proj type
      null, # owner
      eventPlayer.state[SI.BARRIER_DAMAGE_FROM], # start position
      eventPlayer.state[SI.BARRIER_DAMAGE_DIR] , # direction
      Relativity.TO_WORLD, # position relative to
      ModifyHealth.DAMAGE, # damage or heal
      Team.ALL, # affectedTeam
      eventPlayer.state[SI.BARRIER_DAMAGE_STACK], # damage
      0, # damageScalar? for AOE?
      0, # AOE radius
      DynamicEffect.BAD_EXPLOSION, # explosionEffect
      DynamicEffect.EXPLOSION_SOUND, # explosionSound
      0, # oversize
      100, # speed
      5 # lifetime
    )
    eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = 0

  wait(0.5)
  if ruleCondition:
      loop()


rule "Changed player speed":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.CHANGED_SPEED_TIME] > getTotalTimeElapsed()
  @Condition not eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV]

  eventPlayer.setMoveSpeed(eventPlayer.state[SI.CHANGED_SPEED_AMOUNT])
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = eventPlayer.state[SI.CHANGED_SPEED_TIME]

  waitUntil(eventPlayer.state[SI.CHANGED_SPEED_TIME] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)

  if eventPlayer.getTeam() == Team.2:
    eventPlayer.setMoveSpeed(ZOMBIE_SPEED)
  else:
    eventPlayer.setMoveSpeed(PLAYER_SPEED)

  eventPlayer.state[SI.CHANGED_SPEED_TIME] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT] = false


rule "Low gravitation for player":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.LOW_GRAVITY] > getTotalTimeElapsed()

  eventPlayer.setGravity(0)
  waitUntil(eventPlayer.state[SI.LOW_GRAVITY] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)
  eventPlayer.setGravity(100)


rule "[Reinhardt] [Brigitte] Сheck if the barrier is on":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT or eventPlayer.getHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false

rule "[Reinhardt] [Brigitte] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT or eventPlayer.getHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.list0 = (
    [player for player in getPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.2) if (
      distance(player, eventPlayer.getPosition() + eventPlayer.getFacingDirection()) < 2 or (
        not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
        isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) and
        player != eventPlayer
      )
    )]
  )
  eventPlayer.list0.applyImpulse(normalize(eventPlayer.getFacingDirection() + vect(0, 0.2679, 0)), 6, Relativity.TO_WORLD)

  # save information about bots being pushed to account for damage when falling down
  eventPlayer.list0.lastCcAttacker = eventPlayer
  eventPlayer.list0.lastCcAttackTime = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list0.lastCcWasInAir = false

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list0) * (TORBJORN_HAMMER_BASE_DMG * (botsDamageBoostPercent / 100)) * REI_BARRIER_PUSH_ENENT_WAIT
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.getEyePosition() - eventPlayer.state[SI.BARRIER_DAMAGE_FROM])

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()