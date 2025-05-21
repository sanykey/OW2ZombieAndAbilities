#!mainFile "main.opy"

rule "Create hero buy positions":
  heroesList = random.shuffle([ # 43
    # tanks - 13
    Hero.DOOMFIST,
    Hero.JUNKER_QUEEN,
    Hero.MAUGA,
    Hero.ORISA,
    Hero.RAMATTRA,
    Hero.REINHARDT,
    Hero.ROADHOG,
    Hero.SIGMA,
    Hero.WINSTON,
    Hero.WRECKING_BALL,
    Hero.ZARYA,
    Hero.HAZARD,

    # damage dealers - 19
    Hero.ASHE,
    Hero.BASTION,
    Hero.CASSIDY,
    Hero.ECHO,
    Hero.GENJI,
    Hero.HANZO,
    Hero.JUNKRAT,
    Hero.MEI,
    Hero.PHARAH,
    Hero.REAPER,
    Hero.SOJOURN,
    Hero.SOLDIER,
    Hero.SOMBRA,
    Hero.SYMMETRA,
    Hero.TORBJORN,
    Hero.TRACER,
    Hero.VENTURE,
    Hero.WIDOWMAKER,
    Hero.FREJA,

    # supports - 11
    Hero.ANA,
    Hero.BAPTISTE,
    Hero.BRIGITTE,
    Hero.JUNO,
    Hero.KIRIKO,
    Hero.LIFEWEAVER,
    Hero.LUCIO,
    Hero.MERCY,
    Hero.MOIRA,
    Hero.ILLARI,
    Hero.ZENYATTA
  ])

  # [hero, buy_place_vector, price, buy_text_vector]
  heroesShopData = []

  for I in range(len(heroesList)):
    heroesShopData[I] = [
      heroesList[I],
      vectList[I + VI.BUY_HERO_OFFSET],
      floor((
        random.randint(1000, 3500) if I < 6 else (
          random.randint(2500, 5000) if I < 13 else (
            random.randint(4000, 8000) if I < 27 else random.randint(6000, 13000)
          )
        )
      ) / 100) * 100
    ]

    createInWorldText(
      localPlayer,
      "Buy {} ${}\n\n\u3000\u3000\u202f\u202f\u202f\u202f\u202f<TX C00000000021660>
      ".format( #  <TX C0000000001C365> <TX C00000000021660>
        heroIcon(heroesShopData[I][0]),
        heroesShopData[I][2]
      ),
      heroesShopData[I][1],
      1,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY
    )
    # createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, heroesShopData[I][1], 1.7, EffectReeval.VISIBILITY)

  # buy DVA
  heroesShopData[len(heroesList)] = [Hero.DVA, vectList[VI.BUY_DVA], 0]
  createInWorldText(
    getPlayers(Team.1),
    "Buy {}: 0\n\n\u3000\u3000\u202f\u202f\u202f\u202f\u202f<TX C00000000021660>".format(heroIcon(Hero.DVA)),
    vectList[VI.BUY_DVA],
    1,
    Clip.SURFACES,
    WorldTextReeval.VISIBILITY
  )

  # buy CASSIDY (CASSIDY's DAY)
  # heroesShopData[len(heroesList) + 1] = [Hero.CASSIDY, vect(-24.86, -2.00, -10.36), 1000]
  # createInWorldText(getPlayers(Team.1), "Buy {}: $1000".format(heroIcon(Hero.CASSIDY)), vect(-24.86, -2.00, -10.36), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  # createEffect(getPlayers(Team.1), Effect.CLOUD, Color.AQUA, vect(-24.86, -2.00, -10.36), 3, EffectReeval.VISIBILITY)

rule "Buy hero":
  @Event eachPlayer
  @Team 1

  for I in range(len(heroesShopData)):
    # Create tip effects
    if distance(eventPlayer, heroesShopData[I][1]) <= 1.7 and eventPlayer.interactZoneVect != heroesShopData[I][1]:
      eventPlayer.interactZoneVect = heroesShopData[I][1]
      createInWorldText(
          getPlayersInRadius(eventPlayer.interactZoneVect, 4, Team.1),
          "Press {}".format(inputBindingString(Button.INTERACT)),
          eventPlayer.interactZoneVect + Vector.DOWN * 0.2,
          1.3,
          Clip.SURFACES,
          WorldTextReeval.VISIBILITY_AND_STRING
      )
      eventPlayer.interactZoneText = getLastCreatedText()
      createEffect(eventPlayer, Effect.RING, Color.AQUA, eventPlayer.interactZoneVect, 1.7, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
      eventPlayer.interactZoneEffect = getLastCreatedEntity()
    # Destroy tip effect
    elif eventPlayer.interactZoneVect == heroesShopData[I][1] and distance(eventPlayer, heroesShopData[I][1]) > 1.7:
      destroyInWorldText(eventPlayer.interactZoneText)
      destroyEffect(eventPlayer.interactZoneEffect)
      eventPlayer.interactZoneVect = false

    # buy
    if (
      eventPlayer.isHoldingButton(Button.INTERACT) and
      distance(eventPlayer, heroesShopData[I][1]) <= 1.7 and
      eventPlayer.getCurrentHero() != heroesShopData[I][0] and
      eventPlayer.money >= heroesShopData[I][2]
    ):
      eventPlayer.startForcingHero(heroesShopData[I][0])
      playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
      playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
      eventPlayer.money -= heroesShopData[I][2]
      wait(0.25)
      heal(eventPlayer, null, INFINITY)

  wait(0.1)
  if ruleCondition:
      loop()
