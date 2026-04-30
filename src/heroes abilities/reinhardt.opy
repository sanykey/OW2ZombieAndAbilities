#!mainFile "../main.opy"
#!optimizeForSize

#!define REIN_EPICENTER_DIVISIONS 5
#!define REIN_EPICENTER_RADIUS 20
#!define REIN_EPICENTER_WAVES 6
#!define REIN_EPICENTER_STEP 0.1

rule "[Reinhardt] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT

  wait(1) # waiting for the previous hero to clear hero data
  
  setHeroInfoText0(f"<fg94a1a5FF>Reinhardt</fg>:\n
    {abilityIconString(Hero.REINHARDT, Button.SECONDARY_FIRE)} <fg94a1a5FF>Barrier field</fg>:
      - Pushes back enemies and takes damage on contact.\n\n
    {abilityIconString(Hero.REINHARDT, Button.ABILITY_1)} <fg94a1a5FF>Charge</fg>:
      - Press Jump during Charge to launch upward.\n\n
    {abilityIconString(Hero.REINHARDT, Button.ULTIMATE)} <fg94a1a5FF>Earthshatter</fg>:
      - Sends shockwaves in all directions around Reinhardt.
      - Knocks down enemies for 5 seconds.\n\n
    Perk <TX C0000000005E4B2> <fg94a1a5FF>Shield Slam</fg>:
      - Stuns enemies for 2 seconds.
  ", 3)

  waitUntil(eventPlayer.getHero() != Hero.REINHARDT, INFINITY)
  clearHeroInfoSub()


# eventPlayer.heroState0 - Epicenter center position
# eventPlayer.heroState1 - Epicenter is active now
rule "[Reinhardt] Earthshatter Epicenter":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt
  @Condition eventPlayer.isUsingUltimate()
  @Condition not eventPlayer.heroState1

  eventPlayer.heroState1 = true # set Epicenter is active now

  wait(0.15)
  eventPlayer.heroState0 = eventPlayer.getPosition() # set Epicenter center position

  for eventPlayer.I0 in range(REIN_EPICENTER_WAVES):
    tmp0 = (eventPlayer.I0 + 1) * (REIN_EPICENTER_RADIUS / REIN_EPICENTER_DIVISIONS)

    createEffect(
      getAllPlayers(),
      Effect.RING,
      Color.RED,
      eventPlayer.heroState0,
      tmp0,
      EffectReeval.VISIBILITY
    )
    eventPlayer.heroEffectsIds[eventPlayer.I0] = getLastCreatedEntity()

    list0 = [player for player in getPlayersInRadius(
      eventPlayer.heroState0,
      tmp0,
      Team.ZOMBIES,
      LosCheck.SURFACES_AND_ENEMY_BARRIERS
    ) if not player.hasStatus(Status.KNOCKED_DOWN)]

    damage(list0, eventPlayer, 100 / REIN_EPICENTER_DIVISIONS)
    list0.setStatusEffect(null, Status.KNOCKED_DOWN, 5)
    wait(REIN_EPICENTER_STEP)

  wait(1)
  
  for I in range(REIN_EPICENTER_WAVES):
    destroyEffect(eventPlayer.heroEffectsIds[I])

  waitUntil(not eventPlayer.isUsingUltimate(), 3)
  eventPlayer.heroState1 = false


rule "[Reinhardt] Charge jump launch":
  @Event eachPlayer
  @Hero reinhardt
  @Condition eventPlayer.isUsingAbility1()

  waitUntil(not eventPlayer.isUsingAbility1() or eventPlayer.isHoldingButton(Button.JUMP), 5)
  if not eventPlayer.isHoldingButton(Button.JUMP) or not eventPlayer.isUsingAbility1():
    return

  eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
