#!mainFile "main.opy"

rule "Create hero buy positions":
  @Condition roundNumber == 1

  # [hero, buy_place_vector, price, buy_text_vector]
  heroes_shop_data = [
    [Hero.DOOMFIST, vect(12.129, 7.5, -90.424), 2500],
    [Hero.DVA, vect(-18.268, 1.312, -10.4), 0],
    # (Hero.HAZARD, vect(36.879, 14.045, -105.779), 5000],
    [Hero.JUNKER_QUEEN, vect(122.079, 12.303, -64.267), 10000],
    [Hero.MAUGA, vect(-2.191, 3.32, -38.067), 1250],
    [Hero.ORISA, vect(122.424, 13.872, -6.63), 10000],
    [Hero.RAMATTRA, vect(126.145, 12.303, -16.063), 10000],
    [Hero.REINHARDT, vect(10.56, 11.5, -84.54), 2500],
    [Hero.ROADHOG, vect(12.919, 12.617, -100.131), 2500],
    [Hero.SIGMA, vect(133.977, 13.916, -9.824), 10000],
    [Hero.WINSTON, vect(59.56, 7.9, -72.899), 5000], #vect(59.335, 8.042, -72.651)
    [Hero.WRECKING_BALL, vect(55.848, 12, -78.688), 5000],
    [Hero.ZARYA, vect(129.875, 15, -36.803), 10000],

    # damage dealers
    [Hero.ASHE, vect(59.273, 12.953, -59.882), 5000],
    [Hero.BASTION, vect(108.546, 13, -55.139), 10000],
    [Hero.CASSIDY, vect(26.385, 5.328, -32.792), 1250],
    [Hero.ECHO, vect(83, 16, -32), 10000],
    [Hero.GENJI, vect(14.038, 5.338, -18.487), 1250],
    [Hero.HANZO, vect(53.699, 19.357, -80.776), 5000],
    [Hero.JUNKRAT, vect(58.868, 5.974, -91.486), 5000],
    [Hero.MEI, vect(80.335, 13.93, -72.643), 5000],
    [Hero.PHARAH, vect(135.735, 11.8, -28.177), 10000],
    [Hero.REAPER, vect(109.456, 13.5, -24.316), 10000],
    [Hero.SOJOURN, vect(143.171, 13.302, -36.292), 10000],
    [Hero.SOLDIER, vect(79.002, 11.948, -110.348), 5000],
    [Hero.SOMBRA, vect(43.664, 6.549, -50.346), 5000],
    [Hero.SYMMETRA, vect(56.188, 18.974, -110.215), 5000],
    [Hero.TORBJORN, vect(-18.875, 7.812, -85.866), 25000],
    [Hero.TRACER, vect(33.25, 11.333, -93.513), 5000],
    [Hero.VENTURE, vect(27.171, 2.246, -12.287), 1250],
    [Hero.WIDOWMAKER, vect(12.823, 7.312, -57.833), 2500],

    # supports
    [Hero.ANA, vect(1.675, 7.249, -47.434), 2500],
    [Hero.BAPTISTE, vect(-0.898, 5.53, -90.515), 2500],
    [Hero.BRIGITTE, vect(136.347, 13.036, -61.239), 10000],
    [Hero.JUNO, vect(-4.685, 1.321, -8.427), 1250],
    [Hero.KIRIKO, vect(113.847, 12.303, -19.674), 10000],
    [Hero.LIFEWEAVER, vect(36.879, 14.045, -105.779), 5000],
    [Hero.LUCIO, vect(54.407, 22.254, -67.496), 5000],
    [Hero.MERCY, vect(-16.322, 3.247, -31.226), 1250],
    [Hero.MOIRA, vect(102.662, 10.882, -91.232), 5000],
    [Hero.ILLARI, vect(130.268, 12, -57.335), 10000],
    [Hero.ZENYATTA, vect(-1.751, 7.814, -71.73), 5000]
  ]

  for I in range(len(heroes_shop_data)):
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(heroIcon(heroes_shop_data[I][0]), heroes_shop_data[I][2])), heroes_shop_data[I][1], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, heroes_shop_data[I][1], 1.7, EffectReeval.VISIBILITY)

rule "Buy hero":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.F == false

  for I in range(len(heroes_shop_data)):
    if (
      distance(eventPlayer, heroes_shop_data[I][1]) <= 1.7 and
      eventPlayer.getCurrentHero() != heroes_shop_data[I][0] and
      eventPlayer.money >= heroes_shop_data[I][2]
    ):
      eventPlayer.startForcingHero(heroes_shop_data[I][0])
      playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
      playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
      eventPlayer.money -= heroes_shop_data[I][2]
      wait(0.25)
      heal(eventPlayer, null, 99999)