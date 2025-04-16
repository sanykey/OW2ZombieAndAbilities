#!mainFile "main.opy"

rule "[Drop] Total Mayhem":
  @Event playerDied
  @Team 2
  @Slot 0
  
  eventPlayer.healing_tracker = random.randint(1, 35)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[0] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Drop] Points Orb":
  @Event playerDied
  @Team 2
  @Slot 1
  
  eventPlayer.healing_tracker = random.randint(1, 20)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[1] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Drop] Speed Orb":
  @Event playerDied
  @Team 2
  @Slot 2
  @Condition newLine < 40
  
  eventPlayer.healing_tracker = random.randint(1, 25)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[2] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  wait(0.25)
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Drop] Freeze Orb":
  @Event playerDied
  @Team 2
  @Slot 3
  
  eventPlayer.healing_tracker = random.randint(1, 25)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[3] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Drop] Honey, I Shrunk The Team Orb":
  @Event playerDied
  @Team 2
  @Slot 4
  
  eventPlayer.healing_tracker = random.randint(1, 30)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[4] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Drop] Challenge Orb":
  @Event playerDied
  @Team 2
  @Slot 5
  
  eventPlayer.healing_tracker = random.randint(1, 30)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[5] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  wait(0.25)
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:

rule "[Drop] Time Distortion Sphere":
  @Event playerDied
  @Team 2
  @Slot 2
  @Condition newLine > 39
  
  eventPlayer.healing_tracker = random.randint(1, 25)
  if eventPlayer.healing_tracker != 1:
      goto lbl_0
  M[6] = nearestWalkablePosition(eventPlayer) + vect(0, 1, 0)
  lbl_0:
  eventPlayer.setUltCharge(0)
  wait(0.2)
  B -= 1
  wait(0.25)
  if B < 6:
      goto lbl_1
  eventPlayer.respawn()
  lbl_1:


rule "[Points Orb Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[1]) <= 1.5
  @Condition getPlayers(Team.1).G[1] == false
  @Condition newLine >= 1
  
  M[1] = vect(500, 25, 500)
  getPlayers(Team.1).G[1] = true
  getPlayers(Team.1).S[1] = 1
  bigMessage(getAllPlayers(), "2x Points Earned -> 30 Sec")
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.YELLOW, eventPlayer, 5)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  getPlayers(Team.1).H = 2
  wait(30)
  getPlayers(Team.1).H = 1
  getPlayers(Team.1).G[1] = false
  getPlayers(Team.1).S[1] = 0


rule "[Speed Orb Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[2]) <= 1.5
    @Condition getPlayers(Team.1).G[2] == false
    @Condition newLine >= 1
    @Condition newLine < 40
    
    M[2] = vect(500, 25, 500)
    getPlayers(Team.1).G[2] = true
    getPlayers(Team.1).S[2] = 1
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Faster", l"Speed", l"-> {0}".format(l"{0} sec".format(60))))
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 5)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    getPlayers(Team.1).setMoveSpeed(200)
    wait(60)
    getPlayers(Team.1).G[2] = false
    getPlayers(Team.1).S[2] = 0
    getPlayers(Team.1).setMoveSpeed(100)


rule "[Honey, I Shrunk The Team Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[4]) <= 1.5
  @Condition getPlayers(Team.1).G[4] == false
  @Condition newLine >= 1
  
  M[4] = vect(500, 25, 500)
  getPlayers(Team.1).G[4] = true
  getPlayers(Team.1).S[4] = 1
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.HEART), "Honey, I Shrunk The Team! ", iconString(Icon.HEART)))
  getPlayers(Team.1).startModifyingVoicelinePitch(1.5, false)
  getPlayers(Team.1).startScalingSize(0.5, false)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ROSE, eventPlayer, 5)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  wait(0.15)
  getPlayers(Team.1).setJumpVerticalSpeed(300)
  wait(60)
  getPlayers(Team.1).G[4] = false
  getPlayers(Team.1).S[4] = 0
  getPlayers(Team.1).startModifyingVoicelinePitch(1, false)
  getPlayers(Team.1).startScalingSize(1, false)
  getPlayers(Team.1).setJumpVerticalSpeed(100)

rule "[Total Mayhem Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[0]) <= 1.5
  @Condition getPlayers(Team.1).G[0] == false
  @Condition newLine >= 1
  
  M[0] = vect(500, 25, 500)
  getPlayers(Team.1).G[0] = true
  getPlayers(Team.1).S[0] = 1
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.DIZZY), "Total Mayhem -> 30 Sec ", iconString(Icon.DIZZY)))
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 5)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  getPlayers(Team.1).setGravity(25)
  if newLine < 50:
      goto lbl_0
  eventPlayer.setMoveSpeed(200)
  lbl_0:
  wait(30)
  getPlayers(Team.1).G[0] = false
  getPlayers(Team.1).S[0] = 0
  getPlayers(Team.1).setGravity(100)
  if newLine < 50:
      goto lbl_1
  getPlayers(Team.1).setMoveSpeed(100)
  lbl_1:

rule "[Total Mayhem Effects]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[0] == true
  
  getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_1, 0)
  getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_2, 0)
  getPlayers(Team.1).setAbilityCooldown(Button.SECONDARY_FIRE, 0)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
      goto RULE_START


rule "[Challenge Accepted Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[5]) <= 1.5
  @Condition getPlayers(Team.1).G[5] == false
  @Condition newLine >= 1
  
  M[5] = vect(500, 25, 500)
  getPlayers(Team.1).G[5] = true
  getPlayers(Team.1).S[5] = 1
  bigMessage(getAllPlayers(), "[Challenge? Accepted!] Invincible -> 30 Sec")
  smallMessage(getPlayers(Team.1), "Invincible -> 30 Sec")
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 5)
  getPlayers(Team.1).setStatusEffect(null, Status.UNKILLABLE, 30)
  wait(30)
  getPlayers(Team.1).G[5] = false
  getPlayers(Team.1).S[5] = 0

rule "[Freeze Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[3]) <= 1.5
  @Condition getPlayers(Team.1).G[3] == false
  @Condition newLine >= 1
  
  M[3] = vect(500, 25, 500)
  getPlayers(Team.1).G[3] = true
  getPlayers(Team.1).S[3] = 1
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Freezing", l"Zone", l"-> {0}".format(l"{0} sec".format(30))))
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.SKY_BLUE, eventPlayer, 5)
  wait(30)
  getPlayers(Team.1).G[3] = false
  getPlayers(Team.1).S[3] = 0

rule "[Freeze Effects+]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[3] == true
  
  getPlayersInRadius(eventPlayer, 8, Team.2).setStatusEffect(null, Status.FROZEN, 3)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, eventPlayer, 5)
  wait(4)
  if RULE_CONDITION:
      goto RULE_START

rule "[Time Distortion Effects]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, M[6]) <= 1.5
  @Condition getPlayers(Team.1).G[6] == false
  @Condition newLine > 39
  
  M[6] = vect(500, 25, 500)
  getPlayers(Team.1).G[6] = true
  getPlayers(Team.1).S[6] = 1
  bigMessage(getPlayers(Team.1), l"{0} {1} {2}".format(iconString(Icon.SPIRAL), "[Time Distortion] Wibbly, Wobbly, Timey Wimey! -> 30 Sec ", iconString(Icon.SPIRAL)))
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 150)
  setSlowMotion(50)
  getPlayers(Team.2).setDamageReceived(150)
  getPlayers(Team.1).setMoveSpeed(400)
  getPlayers(Team.1).setJumpVerticalSpeed(200)
  wait(15)
  setSlowMotion(100)
  getPlayers(Team.1).G[6] = false
  getPlayers(Team.1).S[6] = 0
  getPlayers(Team.1).setJumpVerticalSpeed(100)
  getPlayers(Team.1).setMoveSpeed(100)
  getPlayers(Team.2).setDamageReceived(100)

rule "[Buffs]: Total Mayhem Ultimate":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[0] == true
  
  eventPlayer.setUltCharge(100)
  wait(5, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
      goto RULE_START