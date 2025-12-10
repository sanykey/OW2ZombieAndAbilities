#!mainFile "../main.opy"

#abilState0 used in bots/zombie behavior.opy:rule "Bots attack near player"
 
rule "[Vendetta] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == newHero

  wait(1) # waiting for the previous hero to clear hero data
  # todo: find Vendetta color:
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fga0a9baFF>Vendetta</fg>:\n
  ".format(
    heroIcon(newHero)
  )

  waitUntil(eventPlayer.getHero() != newHero, INFINITY)
  clearHeroInfo()


rule "[Vendetta] Swirlwind without dash [Ability_1] + [Crouch]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == newHero
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  
  for eventPlayer.temp0 in range(8):
    if (eventPlayer.temp0 == 1 or eventPlayer.temp0 == 5):
      eventPlayer.list0 = [
        player for player in getRealPlayersInRadius(eventPlayer.getPosition(), 4, Team.2) if eventPlayer.isInViewAngle(player.getPosition(), 90)
      ]
      eventPlayer.list0.pushInFacingDirectionAndUp(eventPlayer, 12)
      eventPlayer.list0.setCrowdControlAttack(eventPlayer)
      damage(eventPlayer.list0, eventPlayer, 0.1) # Deal a small amount of damage to earn assist money while holding guard

    eventPlayer.applyImpulse(
      vect(eventPlayer.getFacingDirection().x, 0.2679, eventPlayer.getFacingDirection().z) * -1,
      30,
      Relativity.TO_WORLD,
      Impulse.CANCEL_CONTRARY_MOTION
    )
    wait(0.05)