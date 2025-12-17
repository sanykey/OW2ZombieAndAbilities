#!mainFile "./main.opy"

playervar rayIntersectsSphere

#!define RESULT 0

# [Widowmaker] hitbox position for wallhack shots
#!define ZOMBIE_BODY_HITBOX_RADIUS 0.65
#!define ZOMBIE_HEAD_HITBOX_RADIUS 0.15
#!define WALLHACK_SHOT_IN_VIEW_ANGLE 6

enum RI:
  RESULT
  A
  B
  C
  DISC
  XPXS
  YPYS
  ZPYS
  RADIUS
  SPHERE_POS
  FACING_DIRECTION
  SQRT_RESULT
  T1
  T2


def cRayIntersectionsWithSphereSub():
  @Name "Subroutine: Сalculate the intersections of the ray with the sphere"

  eventPlayer.rayIntersectsSphere[RESULT] = false
  eventPlayer.rayIntersectsSphere[RI.A] = (
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].x * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].x) +
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].y * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].y) +
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].z * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].z)
  )

  eventPlayer.rayIntersectsSphere[RI.XPXS] = eventPlayer.getEyePosition().x - eventPlayer.rayIntersectsSphere[RI.SPHERE_POS].x
  eventPlayer.rayIntersectsSphere[RI.YPYS] = eventPlayer.getEyePosition().y - eventPlayer.rayIntersectsSphere[RI.SPHERE_POS].y
  eventPlayer.rayIntersectsSphere[RI.ZPYS] = eventPlayer.getEyePosition().z - eventPlayer.rayIntersectsSphere[RI.SPHERE_POS].z

  eventPlayer.rayIntersectsSphere[RI.B] = 2 * (
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].x * eventPlayer.rayIntersectsSphere[RI.XPXS]) +
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].y * eventPlayer.rayIntersectsSphere[RI.YPYS]) + 
    (eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].z * eventPlayer.rayIntersectsSphere[RI.ZPYS])
  )

  eventPlayer.rayIntersectsSphere[RI.C] = (
    (eventPlayer.rayIntersectsSphere[RI.XPXS] * eventPlayer.rayIntersectsSphere[RI.XPXS]) +
    (eventPlayer.rayIntersectsSphere[RI.YPYS] * eventPlayer.rayIntersectsSphere[RI.YPYS]) +
    (eventPlayer.rayIntersectsSphere[RI.ZPYS] * eventPlayer.rayIntersectsSphere[RI.ZPYS]) -
    (eventPlayer.rayIntersectsSphere[RI.RADIUS] * eventPlayer.rayIntersectsSphere[RI.RADIUS])
  )

  eventPlayer.rayIntersectsSphere[RI.DISC] = (eventPlayer.rayIntersectsSphere[RI.B] * eventPlayer.rayIntersectsSphere[RI.B]) - (4 * eventPlayer.rayIntersectsSphere[RI.A] * eventPlayer.rayIntersectsSphere[RI.C])

  if eventPlayer.rayIntersectsSphere[RI.DISC] < 0:
    return
  
  #sqrtNewton:
  eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT] = eventPlayer.rayIntersectsSphere[RI.DISC] / 2
  for eventPlayer.temp3 in range(5):
    eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT] = (eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT] + (eventPlayer.rayIntersectsSphere[RI.DISC] / eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT])) / 2

  eventPlayer.rayIntersectsSphere[RI.T1] = ((eventPlayer.rayIntersectsSphere[RI.B] * -1) - eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT]) / (2 * eventPlayer.rayIntersectsSphere[RI.A])
  eventPlayer.rayIntersectsSphere[RI.T2] = ((eventPlayer.rayIntersectsSphere[RI.B] * -1) + eventPlayer.rayIntersectsSphere[RI.SQRT_RESULT]) / (2 * eventPlayer.rayIntersectsSphere[RI.A])

  eventPlayer.rayIntersectsSphere[RI.C] = 0

  if (eventPlayer.rayIntersectsSphere[RI.T1] >= 0 and eventPlayer.rayIntersectsSphere[RI.T2] >= 0):
    eventPlayer.rayIntersectsSphere[RI.C] = eventPlayer.rayIntersectsSphere[RI.T1] if eventPlayer.rayIntersectsSphere[RI.T1] < eventPlayer.rayIntersectsSphere[RI.T2] else eventPlayer.rayIntersectsSphere[RI.T2]
  elif eventPlayer.rayIntersectsSphere[RI.T1] >= 0:
    eventPlayer.rayIntersectsSphere[RI.C] = eventPlayer.rayIntersectsSphere[RI.T1]
  elif eventPlayer.rayIntersectsSphere[RI.T2] >= 0:
    eventPlayer.rayIntersectsSphere[RI.C] = eventPlayer.rayIntersectsSphere[RI.T2]
  else:
    return

  eventPlayer.rayIntersectsSphere[RESULT] = vect(
    eventPlayer.getEyePosition().x + eventPlayer.rayIntersectsSphere[RI.C] * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].x,
    eventPlayer.getEyePosition().y + eventPlayer.rayIntersectsSphere[RI.C] * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].y,
    eventPlayer.getEyePosition().z + eventPlayer.rayIntersectsSphere[RI.C] * eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION].z
  )

macro Player.calcRayIntersectsSphere(self, lineDirection, spherePosition, sphereRadius):
  eventPlayer.rayIntersectsSphere[RI.FACING_DIRECTION] = lineDirection
  eventPlayer.rayIntersectsSphere[RI.SPHERE_POS] = spherePosition
  eventPlayer.rayIntersectsSphere[RI.RADIUS] = sphereRadius
  cRayIntersectionsWithSphereSub()
  # -> eventPlayer.rayIntersectsSphere[RESULT]