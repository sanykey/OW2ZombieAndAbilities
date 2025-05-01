#!mainFile "../main.opy"

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
  @Condition eventPlayer.abilityCD == true
  
  chaseAtRate(eventPlayer.abilityCD, 0, 1)
  waitUntil(not eventPlayer.abilityCD, INFINITY)
  eventPlayer.abilityCD = false
  stopChasingVariable(eventPlayer.abilityCD)
  wait()
  if ruleCondition:
    loop()



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
