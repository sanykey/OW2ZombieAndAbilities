#!mainFile "main.opy"

globalvar heroesList = [Hero.DVA]

rule "Create hero buy positions":
  heroesList.append(random.shuffle(getAllHeroes().exclude(Hero.DVA))) # 43 heroes

  for I in range(VL_BUY_HERO_SPOTS_LEN):
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
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

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
        eventPlayer.money__botStuckTimes >= heroesShopData[I][2]
      ):
        eventPlayer.isDvaUltBought = true
        eventPlayer.money__botStuckTimes -= heroesShopData[I][2]
        eventPlayer.damageResistPercent += DAMAGE_RESISTANCE_BY_OWNED_HERO
        eventPlayer.setDamageReceived(100 - eventPlayer.damageResistPercent)
        eventPlayer.setUltEnabled(true)
        eventPlayer.setUltCharge(100)
        wait()

      eventPlayer.tmp0 = heroesShopData[I][0] in eventPlayer.purchasedHeroes
      if eventPlayer.tmp0 or eventPlayer.money__botStuckTimes >= heroesShopData[I][2]:
        eventPlayer.startForcingHero(heroesShopData[I][0])
        wait(0.1)

        SetHeroTypeSub()

        playEffect(getPlayers(Team.1), DynamicEffect.BAD_PICKUP_EFFECT, Color.AQUA, eventPlayer, 10)
        playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.AQUA, eventPlayer, 50)
        if not eventPlayer.tmp0:
          wait()
          eventPlayer.money__botStuckTimes -= heroesShopData[I][2]
          eventPlayer.purchasedHeroes.append(heroesShopData[I][0])
          eventPlayer.damageResistPercent += DAMAGE_RESISTANCE_BY_OWNED_HERO
          eventPlayer.setDamageReceived(100 - eventPlayer.damageResistPercent)
      
      wait(0.25)
      heal(eventPlayer, null, INFINITY)
      break

