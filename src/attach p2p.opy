#!mainFile "main.opy"

playervar attach2p
enum Attach2P:
  IS_ATTACHED
  PARENT
  POSITION
  HEALTH_POOL
  CHILD

# [Ana][Orisa] Attach Ana to any tank or attach any hero except tanks to Orisa
def AttachP2PSub():
  @Name "Sub: [Ana][Orisa][attach p2p] Attach P2P"
  # Ana can attach to any tank. All players except tanks can attach to Orisa
  eventPlayer.tmp0 = [
    player for player in combatants.exclude(eventPlayer) if (
      not player.attach2p[Attach2P.IS_ATTACHED]
      and (
        eventPlayer.getHero() == Hero.ANA and player.heroType == HeroType.TANK
        or eventPlayer.heroType != HeroType.TANK and player.getHero() == Hero.ORISA
      )
      and distance(eventPlayer.getPosition(), player.getPosition()) < 2
      and not player.isCrowdControlled()
    )
  ]
  
  if not eventPlayer.tmp0:
    return

  #Select parent
  eventPlayer.attach2p[Attach2P.PARENT] = sorted(
    eventPlayer.tmp0,
    lambda i: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), i.getEyePosition()))
  )[0]

  #World Vector
  eventPlayer.attach2p[Attach2P.POSITION] = (
    eventPlayer.attach2p[Attach2P.PARENT].getPosition() 
    + directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.attach2p[Attach2P.PARENT].getPosition(), eventPlayer.getPosition())), 0) 
    * 1 + vect(0, 1, 0)
  )
  #Local vector conversion
  eventPlayer.attach2p[Attach2P.POSITION] = localVector(eventPlayer.attach2p[Attach2P.POSITION], eventPlayer.attach2p[Attach2P.PARENT], Transform.ROTATION_AND_TRANSLATION)
  #Translate player behind parent
  if eventPlayer.attach2p[Attach2P.POSITION].z > 0:
    eventPlayer.attach2p[Attach2P.POSITION] *= vect(1, 1, -1)

  
  eventPlayer.attachTo(eventPlayer.attach2p[Attach2P.PARENT], eventPlayer.attach2p[Attach2P.POSITION])
  eventPlayer.attach2p[Attach2P.PARENT].attach2p[Attach2P.CHILD] = eventPlayer
  eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INFINITY)
  smallMessage(eventPlayer, "You are attached")

  waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), INFINITY) # Prevent detach immediately after attach
  eventPlayer.attach2p[Attach2P.IS_ATTACHED] = true


def DetachP2PSub():
  @Name "Sub: [Ana][Orisa][attach p2p] Detach P2P"
  if eventPlayer.attach2p[Attach2P.CHILD]:
    eventPlayer.tmp0 = eventPlayer.attach2p[Attach2P.CHILD]
    eventPlayer.tmp1 = eventPlayer
  else:
    eventPlayer.tmp0 = eventPlayer
    eventPlayer.tmp1 = eventPlayer.attach2p[Attach2P.PARENT]

  # clear child
  eventPlayer.tmp0.detach()
  eventPlayer.tmp0.clearStatusEffect(Status.INVINCIBLE)
  smallMessage(eventPlayer.tmp0, "You have detached")
  eventPlayer.tmp0.attach2p = []

  # clear parent
  eventPlayer.tmp1.attach2p[Attach2P.CHILD] = null
  

rule "[Ana][Orisa][attach p2p] Detach from player":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.attach2p[Attach2P.IS_ATTACHED]
  @Condition (
    eventPlayer.isHoldingButton(Button.JUMP)
    or not eventPlayer.hasSpawned() 
    or not eventPlayer.attach2p[Attach2P.PARENT].hasSpawned()
    # or not entityExists(eventPlayer.attach2p[Attach2P.PARENT])
    or eventPlayer.isCrowdControlled()
    or eventPlayer.attach2p[Attach2P.PARENT].isCrowdControlled()
    or distance(eventPlayer.getPosition(), eventPlayer.attach2p[Attach2P.PARENT].getPosition()) > 3 # todo: optimize?
  )

  DetachP2PSub()
