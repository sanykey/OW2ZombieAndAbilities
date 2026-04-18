#!mainFile "./main.opy"

# [Widowmaker] hitbox position for wallhack shots
#!define ZOMBIE_BODY_HITBOX_RADIUS 0.65
#!define ZOMBIE_HEAD_HITBOX_RADIUS 0.15
#!define WALLHACK_SHOT_IN_VIEW_ANGLE 6

def RayIntersectionsWithSphereSub():
  @Name "Subroutine: Сalculate the intersections of the ray with the sphere"
  #!optimizeForSize

  # params:
  # param1 - ray direction
  # param2 - sphere center position
  # param3 - sphere radius
  # result:
  # subroutineResult - closest ray/sphere intersection point, or false if there is no forward intersection
  subroutineResult = false

  # tmp0 = A coefficient: dot(rayDirection, rayDirection)
  tmp0 = (
    (param1.x * param1.x) +
    (param1.y * param1.y) +
    (param1.z * param1.z)
  )

  # tmp1 = B coefficient: 2 * dot(rayDirection, rayOrigin - sphereCenter)
  tmp1 = 2 * (
    (param1.x * (eventPlayer.getEyePosition().x - param2.x)) +
    (param1.y * (eventPlayer.getEyePosition().y - param2.y)) + 
    (param1.z * (eventPlayer.getEyePosition().z - param2.z))
  )

  # tmp2 = C coefficient: squared distance from ray origin to sphere center minus squared radius
  tmp2 = (
    ((eventPlayer.getEyePosition().x - param2.x) * (eventPlayer.getEyePosition().x - param2.x)) +
    ((eventPlayer.getEyePosition().y - param2.y) * (eventPlayer.getEyePosition().y - param2.y)) +
    ((eventPlayer.getEyePosition().z - param2.z) * (eventPlayer.getEyePosition().z - param2.z)) -
    (param3 * param3)
  )

  # tmp3 = discriminant. Negative value means the ray misses the sphere.
  tmp3 = (tmp1 * tmp1) - (4 * tmp0 * tmp2)

  if tmp3 < 0:
    return
  
  # tmp2 = first intersection distance along the ray.
  tmp2 = ((tmp1 * -1) - sqrt(tmp3)) / (2 * tmp0)

  # tmp3 = second intersection distance along the ray.
  tmp3 = ((tmp1 * -1) + sqrt(tmp3)) / (2 * tmp0)

  # tmp2 becomes the closest non-negative intersection distance.
  if (tmp2 >= 0 and tmp3 >= 0):
    tmp2 = tmp2 if tmp2 < tmp3 else tmp3
  elif tmp3 >= 0:
    tmp2 = tmp3
  elif tmp2 < 0:
    return

  # subroutineResult = ray origin + ray direction * closest intersection distance
  subroutineResult = vect(
    eventPlayer.getEyePosition().x + tmp2 * param1.x,
    eventPlayer.getEyePosition().y + tmp2 * param1.y,
    eventPlayer.getEyePosition().z + tmp2 * param1.z
  )

macro Player.calcRayIntersectsSphere(self, lineDirection, spherePosition, sphereRadius):
  param1 = lineDirection
  param2 = spherePosition
  param3 = sphereRadius
  RayIntersectionsWithSphereSub()
