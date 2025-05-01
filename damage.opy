#!mainFile "main.opy"

rule "Zombie player took damage":
  @Event playerTookDamage
  @Team 2

  if eventDamage >= 25: # ignore low damage for perfomance
    # save last cc damage from player for fall damage
    if eventAbility == Button.MELEE:
      if victim.isInAir() == false:
        # smallMessage(attacker, "melee CC!")
        victim.state[SI.LAST_CC_ATTACKER] = attacker
        victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
        victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
    elif eventAbility == Button.SECONDARY_FIRE:
      switch attacker.getHero():
        case Hero.DOOMFIST:
        case Hero.JUNKER_QUEEN:
        case Hero.WRECKING_BALL:
        case Hero.ORISA:
        case Hero.BASTION:
        case Hero.ZARYA:
        case Hero.SOLDIER:
        case Hero.VENTURE:
        case Hero.LUCIO:
          # smallMessage(attacker, "secondary fire CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
    elif eventAbility == Button.PRIMARY_FIRE:
      switch attacker.getHero():
        case Hero.REINHARDT:
        case Hero.JUNKRAT: # todo: only on ground
        case Hero.PHARAH: # todo: only on ground
          # smallMessage(attacker, "primary fire CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
        case Hero.JUNKRAT:
        case Hero.PHARAH:
          if victim.isInAir() == false:
            # smallMessage(attacker, "primary fire CC! (JUNKRAT, PHARAH)")
            victim.state[SI.LAST_CC_ATTACKER] = attacker
            victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
            victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
        case Hero.BRIGITTE:
          if attacker.isFiringSecondaryFire() == true:
            # smallMessage(attacker, "primary fire CC! (Brig)")
            victim.state[SI.LAST_CC_ATTACKER] = attacker
            victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
            victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
    elif eventAbility == Button.ABILITY_1:
      switch attacker.getHero():
        case Hero.DVA:
        case Hero.MAUGA:
        case Hero.REINHARDT:
        case Hero.ROADHOG:
        case Hero.WINSTON:
        case Hero.ASHE:
        case Hero.JUNKRAT:
        case Hero.BRIGITTE:
        case Hero.ANA:
        case Hero.ILLARI:
        case Hero.VENTURE:
          # smallMessage(attacker, "ability 1 CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
    elif eventAbility == Button.ABILITY_2:
      switch attacker.getHero():
        case Hero.ORISA:
        case Hero.SIGMA:
        case Hero.RAMATTRA:
        case Hero.CASSIDY:
        case Hero.PHARAH:
          # smallMessage(attacker, "ability 2 CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
    elif eventAbility == Button.ULTIMATE:
      switch attacker.getHero():
        case Hero.DVA:
        case Hero.ORISA:
        case Hero.ROADHOG:
        case Hero.SIGMA:
        case Hero.WINSTON:
        case Hero.ZARYA:
        case Hero.JUNKRAT:
          # smallMessage(attacker, "Ultimate CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
    elif eventAbility == Button.CROUCH:
      switch attacker.getHero():
        case Hero.WRECKING_BALL:
          # smallMessage(attacker, "Crouch CC!")
          victim.state[SI.LAST_CC_ATTACKER] = attacker
          victim.state[SI.LAST_CC_ATTACK_TIME] = 5 + getTotalTimeElapsed()
          victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()
          break
    
  # save damage stats for money
  victim.damageAssitsToSlot[attacker.getSlot()] = 5 + getTotalTimeElapsed()