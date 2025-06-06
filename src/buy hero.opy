#!mainFile "main.opy"

globalvar heroesList = [Hero.DVA]

rule "Create hero buy positions":
  heroesList.append(random.shuffle(getAllHeroes().exclude(Hero.DVA))) # 43 heroes

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


rule "Buy hero":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  for I in range(len(heroesShopData)):
    wait()
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
        wait()

      eventPlayer.temp0 = heroesShopData[I][0] in eventPlayer.purchasedHeroes
      if eventPlayer.temp0 or eventPlayer.money >= heroesShopData[I][2]:
        eventPlayer.startForcingHero(heroesShopData[I][0])
        wait()
        playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
        playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
        if not eventPlayer.temp0:
          wait()
          eventPlayer.money -= heroesShopData[I][2]
          eventPlayer.purchasedHeroes.append(heroesShopData[I][0])
      
      wait(0.25)
      heal(eventPlayer, null, INFINITY)
      break

