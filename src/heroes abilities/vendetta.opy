#!mainFile "../main.opy"
#!optimizeForSize

# eventPlayer.heroState0 - deflect push CD (src/bots/main behavior.opy)

rule "[Vendetta] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.VENDETTA

  wait(1) # waiting for the previous hero to clear hero data

  setHeroInfoText0(
    f"{heroIcon(Hero.VENDETTA)} <fg701315FF>Vendetta</fg>:\n
    {abilityIconString(Hero.KIRIKO, Button.ABILITY_1)} <fgd4878fFF>Swift step</fg>:
      - Can teleport forward without targeting an ally. Increased cooldown: 12 seconds.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.VENDETTA, INFINITY)
  clearHeroInfoSub()


rule "[Vendetta] Swirlwind without dash [Ability_1] + [Crouch]":
  @Event eachPlayer
  @Team 1
  @Hero vendetta
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  
  for eventPlayer.I0 in range(8):
    if (eventPlayer.I0 == 1 or eventPlayer.I0 == 5):
      list0 = [
        player for player in getRealPlayersInRadius(eventPlayer.getPosition(), 4, Team.ZOMBIES) if eventPlayer.isInViewAngle(player.getPosition(), 90)
      ]
      list0.pushInFacingDirectionAndUp(eventPlayer, 12)
      list0.setCrowdControlAttack(eventPlayer)
      damage(list0, eventPlayer, 0.1) # Deal a small amount of damage to earn assist money

    eventPlayer.applyImpulse(
      vect(eventPlayer.getFacingDirection().x, 0.2679, eventPlayer.getFacingDirection().z) * -1,
      30,
      Relativity.TO_WORLD,
      Impulse.CANCEL_CONTRARY_MOTION
    )
    wait(0.05)