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

rule "World Effects":
  @Condition roundNumber == 1

  # "<3" room icons
  createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(139, 12, -18.3), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(114, 12, -11.6), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)

  createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ORANGE, vect(74.955, 13, -52.677), 1, EffectReeval.VISIBILITY)
  createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.BLUE, vect(75.589, 13, -50.533), 1, EffectReeval.VISIBILITY)
  createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ROSE, vect(-18.833, 7.3, -85.965), 1, EffectReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(97.277, 12.025, -32.134), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
  createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ROSE, vect(131, 12.6, 3.8), 5, EffectReeval.VISIBILITY)
  # createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, vect(130.268, 12.998, -57.335), 1.1, EffectReeval.VISIBILITY)
  createEffect(getPlayers(Team.1), Effect.CLOUD, Color.AQUA, vect(-4.685, 0.3, -8.427), 3, EffectReeval.VISIBILITY)

rule "<3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(131, 11.5, 3.8)) <= 5
  
  waitUntil(true, 99999)
  createIcon(getAllPlayers(), eventPlayer, Icon.HEART, IconReeval.NONE, Color.ROSE)
