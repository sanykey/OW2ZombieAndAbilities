#!mainFile "../main.opy"

rule "Enraged Zombies":
  @Event eachPlayer
  @Team 2
  @Slot 0
  @Condition eventPlayer.isAlive() == true

  if (
    roundNumber > 9 and roundNumber < 20 and eventPlayer.getSlot() == 0 or 
    roundNumber > 19 and roundNumber < 30 and eventPlayer.getSlot() < 3 or 
    roundNumber > 29 and roundNumber < 40
  ):
    eventPlayer.startForcingName("Enraged Zombie")
    eventPlayer.setStatusEffect(null, Status.BURNING, INFINITY)
    eventPlayer.startScalingSize(1.5, false)
    wait(2)
    eventPlayer.setUltCharge(100)
    waitUntil(not eventPlayer.isAlive(), INFINITY)
    eventPlayer.startScalingSize(1, false)
  elif roundNumber > 49:
    eventPlayer.startForcingName("Enraged Zombie")
    eventPlayer.startModifyingVoicelinePitch(0.5, false)
    eventPlayer.startScalingSize(1.5, false)
    eventPlayer.setDamageReceived(85)
    eventPlayer.setStatusEffect(null, Status.BURNING, INFINITY)
    wait(1)
    eventPlayer.setUltCharge(random.randint(99, 100))
    eventPlayer.startHealingOverTime(eventPlayer, INFINITY, 150)


rule "Zombie Event description":
  @Condition roundNumber == 10 or roundNumber == 20 or roundNumber == 30 or roundNumber == 50
  
  wait(6)
  if roundNumber == 10:
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies look rather angry... ", iconString(Icon.FIRE)))
  elif roundNumber == 20:
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are getting angrier! ", iconString(Icon.FIRE)))
  elif roundNumber == 30:
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.WARNING), "All Zombies are now permanently Enraged! ", iconString(Icon.WARNING)))
  elif roundNumber == 50:
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are furious! (...Is someone playing DPS Moira?) ", iconString(Icon.FIRE)))
