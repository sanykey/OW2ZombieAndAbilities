#!mainFile "../main.opy"

enum DVA_SI:
  SLIDE_TIME = 0
  SLIDE_EFFECT = 1
  SLIDE_EFFECT2 = 2
  SLIDE_EFFECT3 = 3
  SLIDE_HUD = 4

rule "[DVA] Init":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.DVA

  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent + 50)

  # Slide ability hud:
  hudText(
    eventPlayer if not eventPlayer.state[SI.IS_TALENTS_HUD_OPENNED] else null,
    null,
    "{}{} Slide: {}".format(
      ABILITI_TEXT_INTEND,
      abilityIconString(Hero.TRACER, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>✓</fg> <fg94a0a544>({})</fg>".format(inputBindingString(Button.ABILITY_1))
    ),
    null,
    HudPosition.TOP,
    2.5,
    null,
    Color.WHITE,
    null
  )
  eventPlayer.heroState[DVA_SI.SLIDE_HUD] = getLastCreatedText()

  wait(1) # waiting for the previous hero to clear hero data

  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fged93c7FF>DVA</fg>:\n
  {} {}Slide{}: 
      - Start sliding in the direction you're moving. Press Jump to trigger a high-jump.\n\n
  About vanilla Perks:
      - All perks are useless.
  ".format(
    heroIcon(Hero.DVA),
    abilityIconString(Hero.TRACER, Button.ABILITY_1),
    "<fged93c7FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.DVA, INFINITY)
  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  clearHeroInfo()
  destroyHudText(eventPlayer.heroState[DVA_SI.SLIDE_HUD])


# todo: only without mech
# from [NIGHTSTRIKE](https://workshop.codes/TVKAK)
rule "[DVA] Slide":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.DVA
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
  @Condition eventPlayer.heroState[DVA_SI.SLIDE_TIME] == false

  if eventPlayer.abilityCD:
    return
  
  createEffect(getAllPlayers(), Effect.LUCIO_SOUND_BARRIER_PROTECTED, eventPlayer.getTeam(), eventPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[DVA_SI.SLIDE_EFFECT] = getLastCreatedEntity()

  createEffect(getAllPlayers(), Effect.SIGMA_GRAVITIC_FLUX_TARGET_SOUND, Color.WHITE, eventPlayer, 200, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[DVA_SI.SLIDE_EFFECT2] = getLastCreatedEntity()

  createProjectileEffect(getAllPlayers(), Projectile.GENJI_SHURIKEN, eventPlayer, updateEveryFrame(worldVector(vect(0, 1.25, -0.5), eventPlayer, Transform.ROTATION_AND_TRANSLATION)), vect(0, 0, 0))
  eventPlayer.heroState[DVA_SI.SLIDE_EFFECT3] = getLastCreatedEntity()

  eventPlayer.heroState[DVA_SI.SLIDE_TIME] = 3
  eventPlayer.setMoveSpeed(170)
  eventPlayer.setGravity(0)
  eventPlayer.applyImpulse(directionTowards(eventPlayer, eventPlayer + eventPlayer.getVelocity() + vect(0, -20, 0)), 70, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.1)
  while not eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.heroState[DVA_SI.SLIDE_TIME] > 0:
    eventPlayer.applyImpulse(directionTowards(eventPlayer, eventPlayer + eventPlayer.getFacingDirection() * 2 + eventPlayer.getVelocity() + vect(0, -13, 0)), 4, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.GRAY, worldVector(vect(0, 0, -2), eventPlayer, Transform.ROTATION_AND_TRANSLATION), 1)
    wait(0.1)
    eventPlayer.heroState[DVA_SI.SLIDE_TIME] -= 1
  if eventPlayer.isHoldingButton(Button.JUMP):
    eventPlayer.applyImpulse(directionTowards(eventPlayer, worldVector(vect(0, 10, 5), eventPlayer, Transform.ROTATION_AND_TRANSLATION)), 10, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP, Color.WHITE, eventPlayer.getPosition(), 1)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP_SOUND, Color.WHITE, eventPlayer.getPosition(), 100)

  eventPlayer.setGravity(100)
  eventPlayer.setMoveSpeed(100)
  destroyEffect(eventPlayer.heroState[DVA_SI.SLIDE_EFFECT])
  destroyEffect(eventPlayer.heroState[DVA_SI.SLIDE_EFFECT2])
  destroyEffect(eventPlayer.heroState[DVA_SI.SLIDE_EFFECT3])
  eventPlayer.abilityCD = 8
  eventPlayer.heroState[DVA_SI.SLIDE_TIME] = 0
  
