#!mainFile "main.opy"

rule "[Portal]":
  @Condition shopStatus == true
  
  wait(6)
  createEffect(getAllPlayers(), Effect.BAD_AURA, Color.BLUE, vect(-9.799, 3.5, -27.229), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.BAD_AURA, Color.ORANGE, vect(126.434, 16.5, -15.81), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  bigMessage(getPlayers(Team.1), l"{0} {1} {2}".format(iconString(Icon.SPIRAL), "A portal has appeared nearby...", iconString(Icon.SPIRAL)))


rule "[Portal 1]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(-9.799, 3.147, -27.229)) <= 1.7
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopStatus == true
  
  wait(0.15)
  eventPlayer.teleport(vect(126.4, 18, -15.8))
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.ORANGE, eventPlayer, 100)
  wait(2)


rule "[Portal 2]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(126.434, 16.084, -15.81)) <= 1.7
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopStatus == true
  
  wait(0.15)
  eventPlayer.teleport(vect(-9.8, 6, -27.3))
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.ORANGE, eventPlayer, 100)
  wait(2)