#!mainFile "../main.opy"

enum RAINHARD_SI:
  SHIELD_DAMAGE_STACK = 0


rule "[Reinhard] init":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt



rule "[Reinhard] Damage barrier when pushing enemies every 0.5 sec":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt
  @Condition eventPlayer.isFiringSecondaryFire()

  if eventPlayer.heroState[RAINHARD_SI.SHIELD_DAMAGE_STACK]:
    eventPlayer.temp1 = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
    eventPlayer.temp2 = normalize(eventPlayer.getEyePosition() - eventPlayer.temp1)

    createProjectile(
      Projectile.ORISA_FUSION_DRIVER, # proj type
      null, # owner
      eventPlayer.temp1, # start position
      eventPlayer.temp2, # direction
      Relativity.TO_WORLD, # position relative to
      ModifyHealth.DAMAGE, # damage or heal
      Team.ALL, # affectedTeam
      eventPlayer.heroState[RAINHARD_SI.SHIELD_DAMAGE_STACK], # damage
      0, # damageScalar? for AOE?
      0, # AOE radius
      DynamicEffect.BAD_EXPLOSION, # explosionEffect
      DynamicEffect.EXPLOSION_SOUND, # explosionSound
      0, # oversize
      100, # speed
      5 # lifetime
    )
    eventPlayer.heroState[RAINHARD_SI.SHIELD_DAMAGE_STACK] = 0

  wait(0.5)
  if ruleCondition:
      loop()


rule "[Reinhard] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.temp1 = (
    [player for player in getPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.2) if not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and player != eventPlayer]
  )
  eventPlayer.temp1.applyImpulse(normalize(eventPlayer.getFacingDirection() + vect(0, 0.2679, 0)), 6, Relativity.TO_WORLD)

  eventPlayer.heroState[RAINHARD_SI.SHIELD_DAMAGE_STACK] += len(eventPlayer.temp1) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) / BARRIER_DMG_RESIST_MULT

  wait(0.1)
  if ruleCondition:
      loop()
