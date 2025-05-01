#!mainFile "../main.opy"



# rule "[Juno] Hyper Rift":
#   @Event eachPlayer
#   @Condition eventPlayer.getHero() == Hero.JUNO
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
#   @Condition eventPlayer.isUsingAbility2() == true
  
#   eventPlayer.cancelPrimaryAction()
#   eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)