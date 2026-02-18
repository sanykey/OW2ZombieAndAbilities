#!mainFile "main.opy"

playervar controlsBody
playervar controlledBodyBy

# rule "Create Mirror Bot":
#     @Event eachPlayer
#     @Team 1
#     @Condition eventPlayer.controlsBody
#     @Condition getPlayersInSlot(eventPlayer.getSlot(), Team.1).hasSpawned() == false
    
#     if MirrorAxis == vect(-1, 1, -1):
#         getPlayersInSlot(eventPlayer.getSlot(), Team.1).startThrottleInDirection(eventPlayer.getThrottle(), distance(vect(0, 0, 0), eventPlayer.getThrottle()) * 1, Relativity.TO_PLAYER)
#     else:
#         getPlayersInSlot(eventPlayer.getSlot(), Team.1).startThrottleInDirection(eventPlayer.getThrottle() * vect(-1, 1, 1), distance(vect(0, 0, 0), eventPlayer.getThrottle()) * 1, Relativity.TO_PLAYER)
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).startFacing(eventPlayer.getFacingDirection() * MirrorAxis, 1000)


rule "Do Shoot":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.controlsBody
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  
  eventPlayer.controlsBody.startForcingButton(Button.PRIMARY_FIRE)

rule "Stop Shoot":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.controlsBody
  @Condition not eventPlayer.isFiringPrimaryFire()
  @Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  
  eventPlayer.controlsBody.stopForcingButton(Button.PRIMARY_FIRE)

rule "Do Jump":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.controlsBody
  @Condition eventPlayer.isHoldingButton(Button.JUMP)
  
  eventPlayer.controlsBody.startForcingButton(Button.JUMP)


rule "Stop Jump":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
  
  getPlayersInSlot(eventPlayer.getSlot(), Team.1).stopForcingButton(Button.JUMP)


# rule "Do Ability 1":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
#     @Condition eventPlayer.isCommunicatingEmote() == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).startForcingButton(Button.ABILITY_1)


# rule "Stop Ability 1":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).stopForcingButton(Button.ABILITY_1)


# rule "Do Ability 2":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
#     @Condition eventPlayer.isCommunicatingEmote() == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).startForcingButton(Button.ABILITY_2)


# rule "Stop Ability 2":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).stopForcingButton(Button.ABILITY_2)


# rule "Do Ultimate":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isUsingUltimate() == true
#     @Condition eventPlayer.isCommunicatingEmote() == false
#     @Condition eventPlayer.getHero() != Hero.ANA
#     @Condition eventPlayer.getHero() != Hero.SYMMETRA
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).setUltCharge(100)
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).startForcingButton(Button.ULTIMATE)


# rule "Stop Ultimate":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).stopForcingButton(Button.ULTIMATE)


# rule "Do Crouch":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
#     @Condition eventPlayer.isCommunicatingEmote() == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).startForcingButton(Button.CROUCH)


# rule "Stop Crouch":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.isHoldingButton(Button.CROUCH) == false
    
#     getPlayersInSlot(eventPlayer.getSlot(), Team.1).stopForcingButton(Button.CROUCH)