#!mainFile "main.opy"

def FailedBarrierDeploySub():
  @Name "Subroutine: FailedBarrierDeploy"
  smallMessage(eventPlayer, "Barrier deploy failed! Try again")
  ClearBarrierStateSub()

macro Player.damageBarrier(self, damage):
  self.barrierDamageStack = damage * TORBJORN_HAMMER_BASE_DMG * (zomDamagePct / 100)

macro Player.damageFromBarrier(self, targetPlayers):
  damage(targetPlayers, self, 0.1)

rule "[Ramattra][Reinhardt][Sigma][Winston] Damage barrier":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isActiveBarrier

  if eventPlayer.barrierDamageStack:
    createProjectile(
      Projectile.ORISA_FUSION_DRIVER, # proj type
      null, # owner
      eventPlayer.barrierCheckVectA, # start position
      normalize(eventPlayer.barrierCheckVectB - eventPlayer.barrierCheckVectA), # direction
      Relativity.TO_WORLD, # position relative to
      ModifyHealth.DAMAGE, # damage or heal
      Team.ALL, # affectedTeam
      eventPlayer.barrierDamageStack, # damage
      0, # damageScalar? for AOE?
      0, # AOE radius
      DynamicEffect.BAD_EXPLOSION, # explosionEffect
      DynamicEffect.EXPLOSION_SOUND, # explosionSound
      0, # oversize
      100, # speed
      5 # lifetime
    )
    eventPlayer.barrierDamageStack = 0

  wait(0.5)
  if ruleCondition:
    loop()


rule "[Reinhardt] [Brigitte] Сheck if the barrier is on":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT or eventPlayer.getHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.isActiveBarrier = true
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  ClearBarrierStateSub()

#!define REI_BARRIER_PUSH_ENENT_WAIT 0.1
rule "[Reinhardt] [Brigitte] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT or eventPlayer.getHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  list0 = (
    [player for player in getRealPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.ZOMBIES) if (
      distance(player, eventPlayer.getPosition() + eventPlayer.getFacingDirection()) < 2 or 
      (
        not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
        isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS)
      )
    )]
  )

  list0.pushInFacingDirectionAndUp(eventPlayer, 6)
  list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.damageFromBarrier(list0) # Deal a small amount of damage to earn assist money while holding a shield
  eventPlayer.damageBarrier((3 if eventPlayer.getHero() == Hero.BRIGITTE else 3.65) * REI_BARRIER_PUSH_ENENT_WAIT * len(list0))

  eventPlayer.barrierCheckVectA = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.barrierCheckVectB = eventPlayer.getEyePosition()

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()
