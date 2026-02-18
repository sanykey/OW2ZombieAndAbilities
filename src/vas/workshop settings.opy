#!mainFile "../main.opy"

#!define DEFAULT_STARTING_MONEY 3500
##!define DEFAULT_MAX_ZOMBIES 14
#!define DEFAULT_MAX_ZOMBIES 18

rule "Workshop settings init":
  wSettingsStartMoney = createWorkshopSettingInt("Settings", "Starting money", DEFAULT_STARTING_MONEY, 0, 500000)
  wSettingsMaxZombieBots = createWorkshopSettingInt("Settings", "Max zombie bots", DEFAULT_MAX_ZOMBIES, 1, DEFAULT_MAX_ZOMBIES)