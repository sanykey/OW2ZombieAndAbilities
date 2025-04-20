#!mainFile "main.opy"

rule "Init vars, effects and hud for Orbs":
  # [range_of_chance, round]
  orbs_arr = [ 
    [28, 1], # Total Mayhem (2.8%)
    [78, 1], # Points Orb (5%) 28+50
    [118, 1], # Speed Orb (4%) 28+50+40
    [158, 1], # Freeze Orb (4%) 28+50+40+40
    [191, 1], # Honey, I Shrunk The Team Orb (3.3%) 28+50+40+40+33
    [224, 1], # Challenge Orb (3.3%) 28+50+40+40+33+33
    [264, 40], # Time Distortion Sphere (4%) 28+50+40+40+33+33+40
  ]

  for I in range(len(orbs_arr)):
    orbs_vectors_arr[I] = hiddenVector

  createEffect(getPlayers(Team.1), Effect.ORB, Color.VIOLET, orbs_vectors_arr[0], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.ORB, Color.YELLOW, orbs_vectors_arr[1], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.ORB, Color.GREEN, orbs_vectors_arr[2], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.ORB, Color.AQUA, orbs_vectors_arr[3], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.ORB, Color.ROSE, orbs_vectors_arr[4], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.ORB, Color.ORANGE, orbs_vectors_arr[5], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getPlayers(Team.1), Effect.GOOD_AURA, Color.BLUE, orbs_vectors_arr[6], 0.7, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

  hudHeader([player for player in getPlayers(Team.1) if player.S[1] == 1], l"Points", HudPosition.TOP, 1, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[2] == 1], l"Speed", HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[4] == 1], "Honey, I Shrunk The Team!", HudPosition.TOP, 1, Color.ROSE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[0] == 1], "Total Mayhem", HudPosition.TOP, 1, Color.VIOLET, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[5] == 1], l"Challenge Accepted", HudPosition.TOP, 1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[3] == 1], l"Freezing", HudPosition.TOP, 1, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
  hudHeader([player for player in getPlayers(Team.1) if player.S[6] == 1], "Time Distortion", HudPosition.TOP, 1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

rule "Bot died - drop orb chance":
  @Event playerDied
  @Team 2
  @Condition round_remaining_bots > 0
  
  eventPlayer.orb_roll = random.randint(1, 7000)
  if eventPlayer.orb_roll <= orbs_arr[6][0]:
    for I in range(len(orbs_arr)):
      if eventPlayer.orb_roll <= orbs_arr[I][0] and roundNumber >= orbs_arr[I][1]:
        orbs_vectors_arr[I] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
        break

rule "Points orb effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[1]) <= 1.5
  @Condition getPlayers(Team.1).G[1] == false
  @Condition roundNumber >= 1
  orbs_vectors_arr[1] = hiddenVector
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


rule "Speed orb effects":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, orbs_vectors_arr[2]) <= 1.5
    @Condition getPlayers(Team.1).G[2] == false
    @Condition roundNumber >= 1
    @Condition roundNumber < 40
    
    orbs_vectors_arr[2] = hiddenVector
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


rule "Honey, I Shrunk The Team Effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[4]) <= 1.5
  @Condition getPlayers(Team.1).G[4] == false
  @Condition roundNumber >= 1
  
  orbs_vectors_arr[4] = hiddenVector
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

rule "Total mayhem effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[0]) <= 1.5
  @Condition getPlayers(Team.1).G[0] == false
  @Condition roundNumber >= 1
  
  orbs_vectors_arr[0] = hiddenVector
  getPlayers(Team.1).G[0] = true
  getPlayers(Team.1).S[0] = 1
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.DIZZY), "Total Mayhem -> 30 Sec ", iconString(Icon.DIZZY)))
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 5)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  getPlayers(Team.1).setGravity(25)
  if roundNumber < 50:
      goto lbl_0
  eventPlayer.setMoveSpeed(200)
  lbl_0:
  wait(30)
  getPlayers(Team.1).G[0] = false
  getPlayers(Team.1).S[0] = 0
  getPlayers(Team.1).setGravity(100)
  if roundNumber < 50:
      goto lbl_1
  getPlayers(Team.1).setMoveSpeed(100)
  lbl_1:

rule "Total Mayhem Effects":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[0] == true
  
  getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_1, 0)
  getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_2, 0)
  getPlayers(Team.1).setAbilityCooldown(Button.SECONDARY_FIRE, 0)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
      goto RULE_START


rule "Challenge Accepted Effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[5]) <= 1.5
  @Condition getPlayers(Team.1).G[5] == false
  @Condition roundNumber >= 1
  
  orbs_vectors_arr[5] = hiddenVector
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

rule "Freeze Effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[3]) <= 1.5
  @Condition getPlayers(Team.1).G[3] == false
  @Condition roundNumber >= 1
  
  orbs_vectors_arr[3] = hiddenVector
  getPlayers(Team.1).G[3] = true
  getPlayers(Team.1).S[3] = 1
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Freezing", l"Zone", l"-> {0}".format(l"{0} sec".format(30))))
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.SKY_BLUE, eventPlayer, 5)
  wait(30)
  getPlayers(Team.1).G[3] = false
  getPlayers(Team.1).S[3] = 0

rule "Freeze Effects+":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[3] == true
  
  getPlayersInRadius(eventPlayer, 8, Team.2).setStatusEffect(null, Status.FROZEN, 3)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, eventPlayer, 5)
  wait(4)
  if RULE_CONDITION:
      goto RULE_START

rule "Time Distortion Effects":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, orbs_vectors_arr[6]) <= 1.5
  @Condition getPlayers(Team.1).G[6] == false
  @Condition roundNumber > 39
  
  orbs_vectors_arr[6] = hiddenVector
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

rule "Buffs: Total Mayhem Ultimate":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.G[0] == true
  
  eventPlayer.setUltCharge(100)
  wait(5, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
      goto RULE_START