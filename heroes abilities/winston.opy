#!mainFile "../main.opy"

enum WINSTON_I:
  BARRIER_DAMAGE_STACK = 0
  BARRIER_ACTIVE = 1

rule "[Winston] init":
  @Event eachPlayer
  @Team 1
  @Hero winston

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fga0a9baFF>Winston</fg>:\n
  {} {}Barrier projector</fg>:
      - Pushes enemies outside and takes damage because of it.
  ".format(
    heroIcon(Hero.WINSTON),
    abilityIconString(Hero.WINSTON, Button.ABILITY_2),
    "<fga0a9baFF>"
  )

  waitUntil(eventPlayer.getHero() != Hero.WINSTON, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.state[SI.HERO_INFO_TEXT] = ""


rule "[Winston] Create barrier and save position":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isUsingAbility2()

  eventPlayer.heroState[WINSTON_I.BARRIER_ACTIVE] = true
  eventPlayer.abilityTemp1 = false
  eventPlayer.abilityProjectile = eventPlayer.getEyePosition()
  eventPlayer.abilityPosition = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + Vector.DOWN * 50, null, getAllPlayers(), false).getHitPosition()

  chaseAtRate(eventPlayer.abilityTemp1, 10000, 9.8)
  chaseAtRate(
    eventPlayer.abilityProjectile,
    eventPlayer.abilityPosition,
    eventPlayer.abilityTemp1
  )

  waitUntil(eventPlayer.abilityProjectile == eventPlayer.abilityPosition, 12)
  wait(0.1)

  waitUntil(
    isInLoS(
      eventPlayer.abilityProjectile + Vector.UP * 4.9,
      eventPlayer.abilityProjectile + Vector.UP * 5.1,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilityProjectile + Vector.LEFT * 4.9,
      eventPlayer.abilityProjectile + Vector.LEFT * 5.1,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilityProjectile + Vector.RIGHT * 4.9,
      eventPlayer.abilityProjectile + Vector.RIGHT * 5.1,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilityProjectile + Vector.FORWARD * 4.9,
      eventPlayer.abilityProjectile + Vector.FORWARD * 5.1,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilityProjectile + Vector.BACKWARD * 4.9,
      eventPlayer.abilityProjectile + Vector.BACKWARD * 5.1,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    11.9
  )

  eventPlayer.heroState[WINSTON_I.BARRIER_ACTIVE] = false


rule "[Winston] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.heroState[WINSTON_I.BARRIER_ACTIVE]

  eventPlayer.temp1 = getPlayersInRadius(eventPlayer.abilityProjectile, 6, Team.2)

  for eventPlayer.temp2 in range(len(eventPlayer.temp1)):
    eventPlayer.temp1[eventPlayer.temp2].applyImpulse(normalize(eventPlayer.temp1[eventPlayer.temp2].getPosition() - eventPlayer.abilityProjectile + vect(0, 0.5, 0.866)), 12 - distance(eventPlayer.abilityProjectile, eventPlayer.temp1[eventPlayer.temp2]), Relativity.TO_WORLD)

  eventPlayer.heroState[WINSTON_I.BARRIER_DAMAGE_STACK] += len(eventPlayer.temp1) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) / 5

  wait(0.1)
  if ruleCondition:
    loop()

rule "[Winston] Damage barrier when pushing enemies every 0.5 sec":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.heroState[WINSTON_I.BARRIER_ACTIVE]

  if eventPlayer.heroState[WINSTON_I.BARRIER_DAMAGE_STACK]:
    createProjectile(
      Projectile.ORISA_FUSION_DRIVER, # proj type
      null, # owner
      eventPlayer.abilityProjectile + Vector.UP * 5.5, # start position
      normalize(eventPlayer.abilityProjectile - (eventPlayer.abilityProjectile + Vector.UP * 5.5)) , # direction
      Relativity.TO_WORLD, # position relative to
      ModifyHealth.DAMAGE, # damage or heal
      Team.ALL, # affectedTeam
      eventPlayer.heroState[WINSTON_I.BARRIER_DAMAGE_STACK], # damage
      0, # damageScalar? for AOE?
      0, # AOE radius
      DynamicEffect.BAD_EXPLOSION, # explosionEffect
      DynamicEffect.EXPLOSION_SOUND, # explosionSound
      0, # oversize
      100, # speed
      5 # lifetime
    )
    eventPlayer.heroState[WINSTON_I.BARRIER_DAMAGE_STACK] = 0

  wait(0.5)
  if ruleCondition:
      loop()