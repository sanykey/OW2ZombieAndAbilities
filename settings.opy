#!mainFile "main.opy"
settings {
    "main": {
        "description": "Junkenstein has unleashed his horde of minions upon Adlersbrunn! Your mission is simple...survive as many waves as possible! Tips on how to play can be found in-game. [NEW]: Juno has landed!          ------------------------------------------------------------                   Special thanks and credit goes to Pug and Hannon#21462! Please support Hannon by playing their version here: [81FKK] Not Mine - Added perks",
        "modeName": "[PvE] Zombies Unleashed (hard?)"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": 6,
        "team2Slots": 0,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false,
        "useExperimentalUpdate": true
    },
    "gamemodes": {
        "ctf": {
            "enabled": false,
            "flagDroppedLockTime": 8,
            "flagPickupTime": 5,
            "flagReturnTime": 1,
            "gameLengthInMn": 15,
            "scoreToWin": 9
        },
        "skirmish": {
            "enabledMaps": [
                "eichenwaldeHalloween"
            ],
            "enablePerks": true
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "spawnHealthPacks": "disabled"
        }
    },
    "heroes": {
        "team1": {
            "dva": {
                "damageDealt%": 150,
                "damageReceived%": 85,
                "health%": 183,
                "movementSpeed%": 150,
                "projectileSpeed%": 500,
                "spawnWithoutMech": true,
                "enableUlt": false
            },
            "torbjorn": {
                "ammoClipSize%": 150,
                "damageDealt%": 150,
                "damageReceived%": 90,
                "ability1Cooldown%": 75,
                "jumpVerticalSpeed%": 120,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true
            }
        },
        "team2": {
            "dva": {
                "damageDealt%": 150,
                "damageReceived%": 85,
                "health%": 183,
                "movementSpeed%": 150,
                "projectileSpeed%": 500,
                "enableUlt": false
            },
            "torbjorn": {
                "ammoClipSize%": 150,
                "damageDealt%": 180,
                "damageReceived%": 90,
                "enableAbility1": false,
                "healingReceived%": 40,
                "health%": 200,
                "jumpVerticalSpeed%": 120,
                "movementSpeed%": 70,
                "enableAbility2": false,
                "projectileSpeed%": 0,
                "combatUltGen%": 10,
                "passiveUltGen%": 10,
                "ultGen%": 10,
                "weaponsEnabled": "hammer"
            }
        },
        "allTeams": {
            "ana": {
                "ammoClipSize%": 200,
                "ability2Cooldown%": 45,
                "damageReceived%": 80,
                "movementSpeed%": 125,
                "ability1Cooldown%": 45,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 200,
                "ultGen%": 200
            },
            "ashe": {
                "ammoClipSize%": 150,
                "ability1Cooldown%": 25,
                "ability1SelfKb%": 150,
                "ability2Cooldown%": 50,
                "enableInfiniteAmmo": true,
                "enableSpawningWithUlt": true,
                "ultDuration%": 125,
                "combatUltGen%": 150
            },
            "baptiste": {
                "ammoClipSize%": 150,
                "ability2Cooldown%": 35,
                "movementSpeed%": 125,
                "ability1Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "ultDuration%": 200
            },
            "bastion": {
                "ammoClipSize%": 200,
                "ability1Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "ultDuration%": 150
            },
            "brigitte": {
                "secondaryFireCooldown%": 50,
                "secondaryFireRechargeRate%": 150,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 125,
                "ability2Cooldown%": 50,
                "shieldBashCooldown%": 25,
                "shieldBashKb%": 150,
                "enableSpawningWithUlt": true,
                "ability1Cooldown%": 25,
                "ability1Kb%": 200
            },
            "cassidy": {
                "ammoClipSize%": 250,
                "ability1Cooldown%": 25,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true
            },
            "doomfist": {
                "ammoClipSize%": 150,
                "damageReceived%": 85,
                "ultKb%": 300,
                "movementSpeed%": 125,
                "ability1Cooldown%": 50,
                "secondaryFireCooldown%": 50,
                "secondaryFireKb%": 150,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true,
                "ultDuration%": 150
            },
            "echo": {
                "ammoClipSize%": 150,
                "ability1Cooldown%": 50,
                "ability2Cooldown%": 50,
                "jumpVerticalSpeed%": 150,
                "enableSpawningWithUlt": true,
                "secondaryFireCooldown%": 50
            },
            "genji": {
                "ammoClipSize%": 150,
                "ability2Cooldown%": 50,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true,
                "ability1Cooldown%": 25,
                "ultDuration%": 200
            },
            "hanzo": {
                "ability3Cooldown%": 25,
                "ability3Distance%": 150,
                "movementSpeed%": 125,
                "ability1Cooldown%": 50,
                "enableSpawningWithUlt": true,
                "ability2Cooldown%": 75,
                "ability2Quantity%": 12
            },
            "hazard": {
                "damageReceived%": 90,
                "healingReceived%": 85,
                "ability2Cooldown%": 50
            },
            "illari": {
                "ammoClipSize%": 200,
                "damageDealt%": 125,
                "damageReceived%": 90,
                "healingDealt%": 120,
                "ability2Cooldown%": 25,
                "healingReceived%": 120,
                "movementSpeed%": 125,
                "ability1Cooldown%": 25,
                "solarEnergyMax%": 500,
                "solarEnergyRecharge%": 500,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 125,
                "passiveUltGen%": 125,
                "ultGen%": 125
            },
            "junkerQueen": {
                "ammoClipSize%": 150,
                "ability1Cooldown%": 25,
                "damageReceived%": 85,
                "secondaryFireCooldown%": 50,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true
            },
            "junkrat": {
                "ammoClipSize%": 200,
                "ability1Cooldown%": 50,
                "ability1Kb%": 125,
                "jumpVerticalSpeed%": 150,
                "enableSpawningWithUlt": true,
                "ability2Cooldown%": 25,
                "ultDuration%": 200
            },
            "juno": {
                "ammoClipSize%": 200,
                "damageDealt%": 125,
                "damageReceived%": 90,
                "ability1Cooldown%": 25,
                "ability2Cooldown%": 50,
                "movementSpeed%": 125,
                "secondaryFireCooldown%": 25,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 150
            },
            "kiriko": {
                "damageReceived%": 85,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 125,
                "ability2Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "ability1Cooldown%": 25,
                "ability1Distance%": 300,
                "passiveUltGen%": 150,
                "ultGen%": 150
            },
            "lifeweaver": {
                "ammoClipSize%": 200,
                "healingDealt%": 125,
                "primaryFireRange%": 200,
                "ability2Cooldown%": 25,
                "movementSpeed%": 125,
                "secondaryFireCooldown%": 50,
                "secondaryFireHealth%": 500,
                "ability1Cooldown%": 25,
                "ability1Health%": 250,
                "enableSpawningWithUlt": true,
                "ultHealth%": 300,
                "passiveUltGen%": 150,
                "ultGen%": 150
            },
            "lucio": {
                "ammoClipSize%": 200,
                "ability2Cooldown%": 25,
                "movementSpeed%": 125,
                "secondaryFireCooldown%": 50,
                "secondaryFireKb%": 200,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 150
            },
            "mauga": {
                "ammoClipSize%": 200,
                "ability2Cooldown%": 50,
                "damageReceived%": 85,
                "movementSpeed%": 125,
                "ability1Cooldown%": 50,
                "ability1Kb%": 150,
                "enableSpawningWithUlt": true
            },
            "mei": {
                "ammoClipSize%": 150,
                "ultFreezeRate%": 200,
                "ability1Cooldown%": 50,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 50,
                "primaryFireFreezeDuration%": 120,
                "primaryFireFreezeRate%": 120
            },
            "mercy": {
                "ability1Cooldown%": 10,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 125,
                "enableInfiniteAmmo": true,
                "ability2Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 350,
                "ultGen%": 350
            },
            "moira": {
                "primaryFireMaximumTime%": 250,
                "primaryFireRechargeRate%": 250,
                "ability2Cooldown%": 25,
                "ability2MaxDamage%": 150,
                "ability2MaxHealing%": 150,
                "ability1Cooldown%": 25,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true,
                "ultDuration%": 150,
                "passiveUltGen%": 150
            },
            "orisa": {
                "ammoClipSize%": 150,
                "damageReceived%": 85,
                "secondaryFireCooldown%": 50,
                "ability1Cooldown%": 25,
                "ability2Cooldown%": 25,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true
            },
            "pharah": {
                "ammoClipSize%": 200,
                "ability2Cooldown%": 50,
                "ability2Kb%": 150,
                "passiveMaxTime%": 150,
                "passiveVerticalSpeed%": 150,
                "ability1Acceleration%": 150,
                "ability1Cooldown%": 50,
                "enableSpawningWithUlt": true
            },
            "ramattra": {
                "damageReceived%": 85,
                "movementSpeed%": 125,
                "ability1Cooldown%": 75,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true,
                "secondaryFireCooldown%": 50
            },
            "reaper": {
                "ammoClipSize%": 150,
                "healingDealt%": 10,
                "ability2Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 20,
                "ability1Cooldown%": 25
            },
            "reinhardt": {
                "secondaryFireRechargeRate%": 150,
                "ability1Cooldown%": 25,
                "ability1Kb%": 150,
                "damageReceived%": 85,
                "ability2Cooldown%": 50,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 125,
                "primaryFireKb%": 150,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 150
            },
            "roadhog": {
                "ammoClipSize%": 200,
                "ability1Cooldown%": 25,
                "damageReceived%": 85,
                "movementSpeed%": 125,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true,
                "secondaryFireCooldown%": 50
            },
            "sigma": {
                "ability2Cooldown%": 50,
                "damageReceived%": 85,
                "secondaryFireCooldown%": 50,
                "ability1Cooldown%": 50,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true
            },
            "sojourn": {
                "ability2Cooldown%": 30,
                "ability1Cooldown%": 50,
                "secondaryFireEnergyChargeRate%": 150,
                "enableSpawningWithUlt": true
            },
            "soldier": {
                "ammoClipSize%": 200,
                "ability2Cooldown%": 50,
                "secondaryFireCooldown%": 25,
                "enableSpawningWithUlt": true,
                "ultDuration%": 125
            },
            "sombra": {
                "ammoClipSize%": 250,
                "secondaryFireCooldown%": 50,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true,
                "ability2Cooldown%": 50,
                "ability1Cooldown%": 50
            },
            "symmetra": {
                "ammoClipSize%": 200,
                "movementSpeed%": 125,
                "ability1Cooldown%": 25,
                "enableSpawningWithUlt": true,
                "ability2Cooldown%": 0
            },
            "tracer": {
                "ammoClipSize%": 200,
                "ability1Cooldown%": 50,
                "damageDealt%": 125,
                "movementSpeed%": 125,
                "ability2Cooldown%": 25,
                "enableSpawningWithUlt": true
            },
            "venture": {
                "ability1Cooldown%": 50,
                "ability1Duration%": 150,
                "secondaryFireCooldown%": 30,
                "enableInfiniteAmmo": true,
                "enableSpawningWithUlt": true
            },
            "widowmaker": {
                "ammoClipSize%": 200,
                "damageReceived%": 80,
                "ability1Cooldown%": 25,
                "movementSpeed%": 125,
                "enableSpawningWithUlt": true,
                "ultDuration%": 150,
                "combatUltGen%": 150,
                "passiveUltGen%": 150,
                "ultGen%": 150,
                "ability2Cooldown%": 25
            },
            "winston": {
                "ammoClipSize%": 150,
                "ability2Cooldown%": 50,
                "damageReceived%": 85,
                "ability1Acceleration%": 150,
                "ability1Cooldown%": 50,
                "ability1Kb%": 150,
                "movementSpeed%": 125,
                "ultKb%": 150,
                "enableSpawningWithUlt": true,
                "ultDuration%": 200,
                "combatUltGen%": 150,
                "passiveUltGen%": 150,
                "ultGen%": 150
            },
            "wreckingBall": {
                "ability2Cooldown%": 75,
                "ammoClipSize%": 200,
                "damageReceived%": 85,
                "ultKb%": 150,
                "movementSpeed%": 125,
                "ability3Cooldown%": 75,
                "enableSpawningWithUlt": true
            },
            "zarya": {
                "ammoClipSize%": 150,
                "damageReceived%": 85,
                "movementSpeed%": 125,
                "ability1Cooldown%": 50,
                "secondaryFireKb%": 150,
                "ability2Cooldown%": 50,
                "enableSpawningWithUlt": true
            },
            "zenyatta": {
                "ammoClipSize%": 200,
                "damageDealt%": 120,
                "damageReceived%": 90,
                "healingDealt%": 150,
                "jumpVerticalSpeed%": 150,
                "movementSpeed%": 150,
                "enableSpawningWithUlt": true,
                "passiveUltGen%": 200,
                "ultGen%": 150
            },
            "enabledHeroes": [
                "dva"
            ],
            "general": {
                "ultGen%": 50,
                "combatUltGen%": 50,
                "passiveUltGen%": 50
            }
        }
    }
}