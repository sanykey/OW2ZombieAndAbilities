#!mainFile "../main.opy"

enum BRI_I:
  WHIP_SHOT_CHARGES_HUD

rule "[Brigitte] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.BRIGITTE

  setHeroInfoText0(
    "
    {} <fg8b625eFF>Brigitte</fg>:\n
    {} <fg8b625eFF>Barrier shield</fg>:
      - Pushes back enemies and takes damage on contact.\n\n
    <TX C00000000003339> <fg8b625eFF>Shield bash</fg>:
      - Stuns the target and nearby enemies within a 2-meter radius for 2 seconds.\n\n
    {} <fg8b625eFF>Repair pack</fg>
      - Can be used on yourself if no ally is in your crosshair.\n\n
    ".format(
      heroIcon(Hero.BRIGITTE),
      abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
      abilityIconString(Hero.BRIGITTE, Button.ABILITY_2)
    )
  )

  setHeroInfoText1(
    "
    {} <fg8b625eFF>Whip shot</fg>:
      - Hold the Whip Shot button while activating to launch forward.
      - Gain an additional charge.
    ".format(
      abilityIconString(Hero.BRIGITTE, Button.ABILITY_1)
    ),
    4, 10
  )


  # Grappling Hook charges hud
  hudText(
    eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
    null,
    "{}{} Next Charge in: {}".format(
      ABILITI_TEXT_INTEND, 
      abilityIconString(Hero.BRIGITTE, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD)
    ),
    "{0}{1}".format(ABILITI_CHARGES_INTEND, ["□□", "<fgFFFFFFFF>■</fg>□", "<fgFFFFFFFF>■■</fg>"][eventPlayer.abilState0]),
    HudPosition.TOP,
    2.5,
    null,
    Color.YELLOW, Color.ORANGE
  )
  eventPlayer.heroEffectsIds[BRI_I.WHIP_SHOT_CHARGES_HUD] = getLastCreatedText()
  eventPlayer.abilState0 = 2

  waitUntil(eventPlayer.getHero() != Hero.BRIGITTE, INFINITY)

  clearHeroInfo()
  destroyHudText(eventPlayer.heroEffectsIds[BRI_I.WHIP_SHOT_CHARGES_HUD])

rule "[Brigitte] Whip shot charge":
  @Event eachPlayer
  @Hero brigitte
  @Team 1
  @Condition eventPlayer.isUsingAbility1()
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  eventPlayer.abilState0 -= 1

  if eventPlayer.abilState0 > 0:
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

rule "[Brigitte] Recharge whip shot":
  @Event eachPlayer
  @Hero brigitte
  @Team 1
  @Condition eventPlayer.abilState0 < 2
  
  wait(0.4, Wait.ABORT_WHEN_FALSE)

  eventPlayer.abilityCD = 4
  waitUntil(not eventPlayer.abilityCD, 4)

  eventPlayer.abilState0 += 1
  if ruleCondition:
    loop()

rule "[Brigitte] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero brigitte
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.list0 = (
    [player for player in getPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.2) if (
      distance(player, eventPlayer.getPosition() + eventPlayer.getFacingDirection()) < 2 or (
        not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
        isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) and
        player != eventPlayer
      )
    )]
  )
  eventPlayer.list0.applyImpulse(normalize(eventPlayer.getFacingDirection() + barrierPushVectUpFix), 6, Relativity.TO_WORLD)

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  eventPlayer.barrierDamageStack += len(eventPlayer.list0) * (TORBJORN_HAMMER_BASE_DMG * (botsDamageBoostPercent / 100)) * REI_BARRIER_PUSH_ENENT_WAIT
  eventPlayer.barrierDamageFrom = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.barrierDamageDir = normalize(eventPlayer.getEyePosition() - eventPlayer.barrierDamageFrom)

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()

rule "[Brigitte] Whip Shot position":
  @Event eachPlayer
  @Hero brigitte
  @Condition eventPlayer.isUsingAbility1()
  
  wait(0.2)
  eventPlayer.abilPos0 = eventPlayer.getEyePosition()
  eventPlayer.abilPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 20, null, eventPlayer, false).getHitPosition()
  chaseAtRate(eventPlayer.abilPos0, eventPlayer.abilPos1, 80)
  waitUntil(eventPlayer.abilPos0 == eventPlayer.abilPos1, INFINITY)
  stopChasingVariable(eventPlayer.abilPos0)

rule "[Brigitte] Whip shot - apply impulse forward":
  @Event eachPlayer
  @Hero brigitte
  @Condition eventPlayer.isUsingAbility1()
  
  waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1), 0.192)
  if not eventPlayer.isHoldingButton(Button.ABILITY_1):
    return
  wait(0.08)
  if eventPlayer.isHoldingButton(Button.ABILITY_1) == false:
    return
  eventPlayer.setGravity(0)
  eventPlayer.applyImpulse(Vector.UP, 4, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait()
  eventPlayer.applyImpulse(
    directionTowards(eventPlayer, eventPlayer.abilPos1),
    28 - min(65, abs(verticalAngleTowards(eventPlayer, eventPlayer.abilPos1))) / 4 if verticalAngleTowards(eventPlayer, eventPlayer.abilPos1) < 0 else 28,
    Relativity.TO_WORLD,
    Impulse.CANCEL_CONTRARY_MOTION
  )
  wait(0.25)
  eventPlayer.setGravity(100)


rule "[Brigitte] Use repair packs on yourself":
  @Event eachPlayer
  @Hero brigitte
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
  @Condition eventPlayer.getAbilityCharge(Button.ABILITY_2) > 0
  @Condition eventPlayer.isAlive()
  
  if eventPlayer.isUsingAbility2() or eventPlayer.getHealth() == eventPlayer.getMaxHealth():
    return

  eventPlayer.setAbilityCharge(Button.ABILITY_2, eventPlayer.getAbilityCharge(Button.ABILITY_2) - 1)
  heal(eventPlayer, eventPlayer, 25)
  eventPlayer.startHealingOverTime(eventPlayer, 2, 20)

  playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR, Color.TEAM_1, eventPlayer.getPosition(), 100)
  playEffect(getAllPlayers(), DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer.getPosition(), 100)

# rule "[Brigitte] debug":
#   @Event eachPlayer
#   @Team 1

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1,
#     6,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

  