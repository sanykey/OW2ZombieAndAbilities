#!mainFile "../main.opy"

globalvar debugMode
globalvar debugModesArr = []
globalvar debugModeHud
globalvar debugUnlimitUltimates = false
globalvar debugSelectedAction
globalvar debugMaxAction
globalvar debugIsNoclip
globalvar debugNoclipPrevHero
globalvar debugBotsSpawnPointEffect
globalvar debugNoCD
globalvar defaultVector = vect(0, 0, 0)
playervar inputThrottle
globalvar debugAllowInput

macro localPlayerVisibilityForDevelopers():
  localPlayer if localPlayer.developer or localPlayer == hostPlayer else null

def ConvertThrottleSR():
  @Name "SUB: [debug] convert throttle"
  eventPlayer.inputThrottle = eventPlayer.getThrottle()
  eventPlayer.inputThrottle = vect(0 if (eventPlayer.inputThrottle.x >= -0.25 and eventPlayer.inputThrottle.x <= 0.25) == true else 1 if eventPlayer.inputThrottle.x > 0.25 else -1, 0, 0 if (eventPlayer.inputThrottle.z >= -0.25 and eventPlayer.inputThrottle.z <= 0.25) == true else 1 if eventPlayer.inputThrottle.z > 0.25 else -1)

rule "[debug] Option throttle check":
  @Event eachPlayer
  @Condition debugMenuIsOpened
  @Condition eventPlayer.getThrottle() != defaultVector
  @Condition magnitude(eventPlayer.getThrottle()) >= 0.5
  
  ConvertThrottleSR()
  waitUntil(magnitude(eventPlayer.getThrottle()) < 0.5, 0.25)
  wait()
  if ruleCondition:
    loop()
  eventPlayer.inputThrottle = defaultVector

rule "[debug] holding Interact while debug menu opened":
  @Event eachPlayer
  @Condition debugMenuIsOpened
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

  eventPlayer.setMoveSpeed(0)
  eventPlayer.setGravity(0)
  eventPlayer.disallowButton(Button.MELEE)
  eventPlayer.disallowButton(Button.PRIMARY_FIRE)
  eventPlayer.disallowButton(Button.SECONDARY_FIRE)
  eventPlayer.disallowButton(Button.ULTIMATE)
  eventPlayer.disallowButton(Button.ABILITY_1)
  eventPlayer.disallowButton(Button.ABILITY_2)
  
  waitUntil(eventPlayer.inputThrottle == defaultVector or not eventPlayer.isHoldingButton(Button.INTERACT), INFINITY)
  if eventPlayer.isHoldingButton(Button.INTERACT):
    debugAllowInput = true
  waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), INFINITY)

  eventPlayer.setMoveSpeed(100)
  eventPlayer.setGravity(100)
  eventPlayer.allowButton(Button.MELEE)
  eventPlayer.allowButton(Button.PRIMARY_FIRE)
  eventPlayer.allowButton(Button.SECONDARY_FIRE)
  eventPlayer.allowButton(Button.ULTIMATE)
  eventPlayer.allowButton(Button.ABILITY_1)
  eventPlayer.allowButton(Button.ABILITY_2)
  debugAllowInput = false

macro debugSelectedActionText(index):
  "<fgecbe52FF>•" if debugSelectedAction == index else "<fgffffffFF>"

def openCloseDebugMenuSR():
  @Name "Subroutine: open/close debug menu"
  debugMenuIsOpened = not debugMenuIsOpened

# rule "[debug] Fast open/close debug menu for developer":
#   @Event eachPlayer
#   @Condition eventPlayer.developer
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT)

#   waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), 0.3)
#   if eventPlayer.isHoldingButton(Button.INTERACT):
#     return
#   waitUntil(eventPlayer.isHoldingButton(Button.INTERACT), 0.3)
#   if eventPlayer.isHoldingButton(Button.INTERACT):
#     openCloseDebugMenuSR()

macro ConditionForDebugMenuInteract():
  @Event eachPlayer
  @Condition debugMenuIsOpened
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

macro RuleHeaderDebugPageInteractCondition(name):
  ConditionForDebugMenuInteract()
  @Condition debugModesArr[debugMode] == name

macro ConditionForActivateSelectedAction(name):
  RuleHeaderDebugPageInteractCondition(name)
  @Condition eventPlayer.isHoldingButton(Button.MELEE)

macro RuleHeaderForDebugMenuInputThrottle(type):
  ConditionForDebugMenuInteract()
  @Condition debugAllowInput
  @Condition eventPlayer.inputThrottle == type

macro ConditionForInitMode(name):
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == name

macro incWithModificators(value):
  (
    (10 * value) if eventPlayer.isHoldingButton(Button.CROUCH)
    else (100 * value) if eventPlayer.isHoldingButton(Button.JUMP)
    else value
  )

macro leftArrowForMenuItem(actionNum):
  "←" if debugSelectedAction == actionNum else ""

macro rightArrowForMenuItem(actionNum):
  "→" if debugSelectedAction == actionNum else ""

rule "[debug] open/close debug menu":
  @Event eachPlayer
  @Condition eventPlayer.developer or eventPlayer == hostPlayer
  @Condition (
    eventPlayer.isHoldingButton(Button.INTERACT)
    and eventPlayer.isHoldingButton(Button.ABILITY_2)
    and eventPlayer.isHoldingButton(Button.ABILITY_1)
  )

  eventPlayer.setStatusEffect(null, Status.STUNNED, 0.3)
  openCloseDebugMenuSR()

rule "[debug] fast ressurect":
  ConditionForDebugMenuInteract()
  @Condition not eventPlayer.isAlive()
  @Condition eventPlayer.isHoldingButton(Button.RELOAD)
  eventPlayer.teleport(nearestWalkablePosition(eventPlayer))
  eventPlayer.resurrect()

macro debugMenuTitle(name):
  "Debug menu:
  {}Page: {} <fg84c951FF>{}</fg> {} <fg94a0a544>← [ULTIMATE/ABILITY_2] →</fg>".format(
    debugSelectedActionText(0), 
    "←" if not debugSelectedAction else "",
    name,
    "→</fg>" if not debugSelectedAction else "</fg>"
  )

def NextDebugMenuPageSub():
  @Name "SUB: [debug] Next debug menu page"
  if debugMode >= len(debugModesArr) - 1:
    debugMode = 0
  else:
    debugMode++

def PrevDebugMenuPageSub():
  @Name "SUB: [debug] Prev debug menu page"
  if debugMode <= 0:
    debugMode = len(debugModesArr) - 1
  else:
    debugMode--

rule "[debug] (Throttle Right) next page menu":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition not debugSelectedAction
  NextDebugMenuPageSub()

rule "[debug] (Throttle Left) prev page menu":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition not debugSelectedAction
  PrevDebugMenuPageSub()

rule "[debug] (ABILITY_2) next page menu":
  ConditionForDebugMenuInteract()
  @Condition debugAllowInput
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
  NextDebugMenuPageSub()

rule "[debug] (ULTIMATE) prev page menu":
  ConditionForDebugMenuInteract()
  @Condition debugAllowInput
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
  PrevDebugMenuPageSub()

rule "[debug] (Down) select debug menu action":
  RuleHeaderForDebugMenuInputThrottle(Vector.BACKWARD)
  if debugSelectedAction >= debugMaxAction:
    debugSelectedAction = 0
  else:
    debugSelectedAction++

rule "[debug] (UP) select debug menu action":
  RuleHeaderForDebugMenuInputThrottle(Vector.FORWARD)
  if debugSelectedAction <= 0:
    debugSelectedAction = debugMaxAction
  else:
    debugSelectedAction--

def RemoveBotsSub():
  @Name "SUB: [debug] remove bots"
  isBotsDisabled = true
  destroyAllDummies()

  if roundNumber > 0:
    roundNumber -= 1
  roundRemainingBots = 0
  smallMessage(eventPlayer, "Bots removed")

def AddBotsSub():
  isBotsDisabled = false
  smallMessage(eventPlayer, "Bots added")