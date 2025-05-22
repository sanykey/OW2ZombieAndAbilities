#!mainFile "main.opy"

#!define BUY_HERO_OFFSET_A 0
#!define BUY_HERO_OFFSET_B VL_BUY_HERO_SPOTS_A_LEN
#!define BUY_HERO_OFFSET_E BUY_HERO_OFFSET_B + VL_BUY_HERO_SPOTS_B_LEN
#!define BUY_HERO_OFFSET_I BUY_HERO_OFFSET_E + VL_BUY_HERO_SPOTS_E_LEN
#!define BUY_HERO_OFFSET_H BUY_HERO_OFFSET_I + VL_BUY_HERO_SPOTS_I_LEN

rule "Create hero buy positions":
  heroesList = [Hero.DVA]
  heroesList.append(random.shuffle(getAllHeroes().exclude(Hero.DVA))) # 43 heroes

  # [hero, buy_place_vector, price, buy_text_vector]
  heroesShopData = []

  for I in range(len(heroesList)):
    heroesShopData[I] = [
      heroesList[I],
      vectList[I + VL_BUY_HERO_SPOTS_OFFSET],
      floor((
        7000 if I == 0 else ( # DVA
          random.randint(1000, 3500) if I < BUY_HERO_OFFSET_B else (
            random.randint(2500, 5000) if I < BUY_HERO_OFFSET_E else (
              random.randint(4000, 8000) if I < BUY_HERO_OFFSET_I else (
                random.randint(6000, 13000)
              )
            )
          )
        )
      ) / 100) * 100
    ]

    # createInWorldText(
    #   getPlayers(Team.1),
    #   "Buy {} ${}\n\n\u3000\u3000\u202f\u202f\u202f\u202f\u202f<TX C00000000021660>".format(
    #     "<TX C00000000004EAB>{}".format(heroIcon(Hero.DVA)) if heroesShopData[I][0] == Hero.DVA else heroIcon(heroesShopData[I][0]),
    #     heroesShopData[I][2]
    #   ),
    #   heroesShopData[I][true],
    #   true,
    #   Clip.SURFACES,
    #   WorldTextReeval.VISIBILITY
    # )
    # createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, heroesShopData[I][1], 1.7, EffectReeval.VISIBILITY)


rule "Buy hero":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  for I in range(len(heroesShopData)):
    if (
      distance(eventPlayer, heroesShopData[I][1]) <= 1.7 and
      (eventPlayer.getCurrentHero() != heroesShopData[I][0] or heroesShopData[I][0] == Hero.DVA)
    ):

      # buy DVA mech
      if (
        heroesShopData[I][0] == Hero.DVA and
        not eventPlayer.isDvaUltBought and
        eventPlayer.money >= heroesShopData[I][2]
      ):
        eventPlayer.isDvaUltBought = true
        eventPlayer.money -= heroesShopData[I][2]
        eventPlayer.setUltEnabled(true)
        eventPlayer.setUltCharge(100)

      eventPlayer.temp0 = heroesShopData[I][0] in eventPlayer.purchasedHeroes
      if eventPlayer.temp0 or eventPlayer.money >= heroesShopData[I][2]:
        eventPlayer.startForcingHero(heroesShopData[I][0])
        playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
        playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
        if not eventPlayer.temp0:
          eventPlayer.money -= heroesShopData[I][2]
          eventPlayer.purchasedHeroes.append(heroesShopData[I][0])
      
      wait(0.25)
      heal(eventPlayer, null, INFINITY)
      break

# rule "Buy hero":
#   @Event eachPlayer
#   @Team 1

#   for I in range(len(heroesShopData)):
#     # Create tip effects
#     if distance(eventPlayer, heroesShopData[I][true]) <= 1.7 and eventPlayer.interactZoneVect != heroesShopData[I][true]: 
#       eventPlayer.interactZoneVect = heroesShopData[I][true]
#       createInWorldText(
#         getPlayersInRadius(eventPlayer.interactZoneVect, 4, Team.1),
#         "Press {}".format(inputBindingString(Button.INTERACT)),
#         eventPlayer.interactZoneVect + Vector.DOWN * 0.1,
#         1.3,
#         Clip.SURFACES,
#         WorldTextReeval.VISIBILITY_AND_STRING
#       )
#       eventPlayer.interactZoneText = getLastCreatedText()
#       createEffect(eventPlayer, Effect.RING, Color.AQUA, eventPlayer.interactZoneVect, 1.7, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
#       eventPlayer.interactZoneEffect = getLastCreatedEntity()
#     # Destroy tip effect
#     elif eventPlayer.interactZoneVect == heroesShopData[I][true] and distance(eventPlayer, heroesShopData[I][true]) > 1.7:
#       destroyInWorldText(eventPlayer.interactZoneText)
#       destroyEffect(eventPlayer.interactZoneEffect)
#       eventPlayer.interactZoneVect = false

#     # buy
#     if (
#       eventPlayer.isHoldingButton(Button.INTERACT) and
#       distance(eventPlayer, heroesShopData[I][true]) <= 1.7 and
#       eventPlayer.getCurrentHero() != heroesShopData[I][0] and
#       eventPlayer.money >= heroesShopData[I][2]
#     ):
#       eventPlayer.startForcingHero(heroesShopData[I][0])
#       playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
#       playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
#       if not heroesShopData[I][0] in eventPlayer.purchasedHeroes == true:
#         eventPlayer.money -= heroesShopData[I][2]
#         eventPlayer.purchasedHeroes.append(heroesShopData[I][0])
#       wait(0.25)
#       heal(eventPlayer, null, INFINITY)

#   wait(0.1)
#   if ruleCondition:
#     loop()
