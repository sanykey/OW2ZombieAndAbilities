#!mainFile "../main.opy"

#abilState0 used in bots/zombie behavior.opy:rule "Bots attack near player"
 
rule "[Vendetta] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.VENDETTA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg701315FF>Vendetta</fg>:\n
  ".format(
    heroIcon(Hero.VENDETTA)
  )

  waitUntil(eventPlayer.getHero() != Hero.VENDETTA, INFINITY)
  clearHeroInfo()


rule "[Vendetta] Swirlwind without dash [Ability_1] + [Crouch]":
  @Event eachPlayer
  @Team 1
  @Hero vendetta
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  
  for eventPlayer.tmp0 in range(8):
    if (eventPlayer.tmp0 == 1 or eventPlayer.tmp0 == 5):
      eventPlayer.list0 = [
        player for player in getRealPlayersInRadius(eventPlayer.getPosition(), 4, Team.ZOMBIES) if eventPlayer.isInViewAngle(player.getPosition(), 90)
      ]
      eventPlayer.list0.pushInFacingDirectionAndUp(eventPlayer, 12)
      eventPlayer.list0.setCrowdControlAttack(eventPlayer)
      damage(eventPlayer.list0, eventPlayer, 0.1) # Deal a small amount of damage to earn assist money

    eventPlayer.applyImpulse(
      vect(eventPlayer.getFacingDirection().x, 0.2679, eventPlayer.getFacingDirection().z) * -1,
      30,
      Relativity.TO_WORLD,
      Impulse.CANCEL_CONTRARY_MOTION
    )
    wait(0.05)