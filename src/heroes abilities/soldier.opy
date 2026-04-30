#!mainFile "../main.opy"
#!optimizeForSize

# rule "[Soldier] init":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.getHero() == Hero.SOLDIER

#   waitUntil(eventPlayer.getHero() != Hero.SOLDIER, INFINITY)
#   clearHeroInfoSub()

# rule "[Soldier] Helix rockets with ultimate":
#   @Event eachPlayer
#   @Hero soldier
#   @Condition eventPlayer.isUsingUltimate()

#   eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
#   wait(1)
#   if ruleCondition:
#     loop()
