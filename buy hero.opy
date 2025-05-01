#!mainFile "main.opy"

rule "Create hero buy positions":
  @Condition roundNumber == 1

  heroesList = [ # 41
    # tanks - 12
    Hero.DOOMFIST,
    # Hero.HAZARD
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

    # damage dealers - 18
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
  ]

  # [hero, buy_place_vector, price, buy_text_vector]
  heroesShopData = []

  # shuffle heroes list
  for I in range(len(heroesList) - 1, 0, -1):
    J = random.randint(0, I)
    temp1 = heroesList[J]
    heroesList[J] = heroesList[I]
    heroesList[I] = temp1

  for I in range(len(heroesList)):
    heroesShopData[I] = [heroesList[I], vectList[I + vectListI.BUY_HERO_OFFSET], random.randint(2500, 15000)]

    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(heroIcon(heroesShopData[I][0]), heroesShopData[I][2])), heroesShopData[I][1], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, heroesShopData[I][1], 1.7, EffectReeval.VISIBILITY)

  # buy DVA
  heroesShopData[len(heroesList)] = [Hero.DVA, vectList[vectListI.BUY_DVA], 0]
  createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(heroIcon(Hero.DVA), 0)), vectList[vectListI.BUY_DVA], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, vectList[vectListI.BUY_DVA], 1.7, EffectReeval.VISIBILITY)

rule "Buy hero":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  for I in range(len(heroesShopData)):
    if (
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