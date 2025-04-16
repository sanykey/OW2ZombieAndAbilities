#!mainFile "main.opy"
rule "[Enraged Zombies - 10]":
  @Event eachPlayer
  @Team 2
  @Slot 0
  @Condition newLine > 9
  @Condition eventPlayer.isAlive() == true
  @Condition newLine < 20
  
  eventPlayer.startForcingName("Enraged Zombie")
  wait(1)
  eventPlayer.startScalingSize(1.5, false)


rule "[Enraged Zombies - 10]":
  @Event eachPlayer
  @Team 2
  @Slot 0
  @Condition newLine > 9
  @Condition eventPlayer.isAlive() == true
  @Condition newLine < 20
  
  eventPlayer.setUltCharge(100)
  wait(2)
  eventPlayer.setStatusEffect(null, Status.BURNING, 9999)

rule "Zombie Event [10]":
  @Condition newLine == 10
  
  wait(6)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies look rather angry... ", iconString(Icon.FIRE)))

rule "Enraged Zombies [50]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 49
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)
    eventPlayer.setDamageReceived(85)
    eventPlayer.startHealingOverTime(eventPlayer, 9999, 150)


rule "Enraged Zombies [50]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 49
    
    eventPlayer.startModifyingVoicelinePitch(0.5, false)
    eventPlayer.setUltCharge(random.randint(99, 100))
    wait(2)
    getPlayersOnHero(Hero.TORBJORN, Team.2).setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [30]":
    @Condition newLine == 30
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.WARNING), "All Zombies are now permanently Enraged! ", iconString(Icon.WARNING)))


rule "Enraged Zombies [20]":
  @Event eachPlayer
  @Team 2
  @Slot 0
  @Condition newLine > 19
  @Condition eventPlayer.isAlive() == true
  @Condition newLine < 30
  
  eventPlayer.startForcingName("Enraged Zombie")
  wait(1)
  eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 0
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [20]":
    @Condition newLine == 20
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are getting angrier! ", iconString(Icon.FIRE)))


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 1
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 2
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 1
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 2
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [50]":
    @Condition newLine == 50
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are furious! (...Is someone playing DPS Moira?) ", iconString(Icon.FIRE)))


rule "Enraged Zombies [30]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 29
    @Condition newLine < 40
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [30]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 29
    @Condition newLine < 40
    
    eventPlayer.setUltCharge(random.randint(99, 100))
    wait(2)
    getPlayersOnHero(Hero.TORBJORN, Team.2).setStatusEffect(null, Status.BURNING, 9999)

