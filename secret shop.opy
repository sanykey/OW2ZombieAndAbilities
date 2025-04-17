#!mainFile "main.opy"

rule "[Secret Room Effects]":
  @Condition D == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vect(97.513, 16.972, -20.29), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  N[0] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), l"{0} {1}".format(l"Connect", l"Power"), vect(97.513, 16.972, -20.29), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  N[1] = getLastCreatedText()
  createInWorldText(getAllPlayers(), l"#{0}".format(iconString(Icon.ARROW_LEFT)), vect(90.42, 17.169, -17.775), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)


rule "[Power Switch ON]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(97.513, 16.972, -20.29)) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition K == 0
  @Condition D == 1
  
  destroyEffect(N[0])
  destroyInWorldText(N[1])
  N = 1
  K = 1
  bigMessage(getAllPlayers(), l"{0} {1}".format(l"Power", l"On"))
  F = 0
  G = random.choice(H)

rule "[Teleporter A]":
  @Condition K == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  J[0] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.NO), vect(123.312, 9.176, -27.364), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  J[1] = getLastCreatedText()
  wait(1)
  J[2] = random.choice(I)
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, J[2], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  J[3] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), J[2], 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  J[4] = getLastCreatedText()


rule "[Teleporter B]":
    @Condition K == 2
    
    destroyEffect(J[0])
    destroyInWorldText(J[1])
    destroyEffect(J[3])
    destroyInWorldText(J[4])
    createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    J[5] = getLastCreatedEntity()
    createInWorldText(getAllPlayers(), "-> [Shop] <-", vect(123.312, 10.5, -27.364), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
    J[6] = getLastCreatedText()
    bigMessage(getAllPlayers(), "The secret shop has temporarily opened!")
    wait(60)
    K = 3


rule "[Teleporter C]":
    @Condition K == 3
    
    destroyEffect(J[5])
    destroyInWorldText(J[6])
    bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Offline]")
    wait(180)
    K = 1
    bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Online]")


rule "[Secret Shop Power ON]":
    @Condition roundNumber == 1
    
    I = []
    #I.append(vect(121.74, 12.034, -65.345))
    #I.append(vect(135.084, 16.051, -35.406))
    #I.append(vect(126.233, 12.035, -16.35))
    I.append(vect(112.572, 10.034, -30.484))
    #I.append(vect(87.192, 14.034, -40.809))
    #I.append(vect(99.11, 14.045, -61.446))
    #I.append(vect(128.287, 15.034, -8.08))
    #I.append(vect(107.671, 12.034, -31.942))
    J[2] = hidden_vector


rule "[Teleporter Switch]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, J[2]) <= 1.5
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition K == 1
    
    K = 2


rule "[Teleport Players To Secret Shop]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(123.312, 9.176, -27.364)) <= 5
    @Condition K == 2
    @Condition eventPlayer.F == false
    @Condition eventPlayer.J == 0
    
    eventPlayer.J = 1
    eventPlayer.teleport(vect(-16.309, 8.115, -89.008))
    wait(30)
    if eventPlayer.J == 0:
        goto lbl_0
    smallMessage(eventPlayer, "Leaving in 5...")
    wait(1)
    smallMessage(eventPlayer, 4)
    wait(1)
    smallMessage(eventPlayer, 3)
    wait(1)
    smallMessage(eventPlayer, 2)
    wait(1)
    smallMessage(eventPlayer, 1)
    wait(1)
    lbl_0:
    if eventPlayer.J == 0:
        goto lbl_1
    eventPlayer.teleport(vect(113.354, 16.189, -29.761))
    lbl_1:
    eventPlayer.J = 0


rule "[Exit Secret Shop]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-8.2, 10.2, -76.2)) <= 2.5
    
    eventPlayer.teleport(vect(113.354, 16.189, -29.761))
    eventPlayer.J = 0

rule "[Auto Heal Secret Shop]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(-20.695, 7.574, -86.552)) < 12

  wait(1)
  heal(eventPlayer, null, 99999)
  wait(2)

rule "[Exit In-World Text Secret Shop]":
  createInWorldText(getAllPlayers(), "[Exit]", vect(-8.216, 10.262, -76.205), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  createInWorldText(getAllPlayers(), "[No Exit]", vect(-11.251, 6.5, -87.359), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)