#!mainFile "main.opy"
rule "Create location buy positions":
  # init vectors
    B = compress([
    # Effects for purchase access to locked areas [0-3]
    vect(7.613, 5.326, -34.916),
    vect(31.577, 6.126, -62.399),
    vect(99.296, 13.977, -72.064),
    vect(86.651, 14.036, -32.931),

    # Areas in doorways that push away approaching players when the doorway is not yet open [4-12] 
    vect(19, 7, -50.013),
    vect(40.631, 8.265, -77.59),
    vect(51.561, 8.095, -58.373),
    vect(23.088, 12.063, -89.42),
    vect(78.65, 14.171, -53.779),
    vect(103.219, 15.554, -60.019),
    vect(91.888, 22.491, -53.112),
    vect(87.651, 15, -28.387),
    vect(107.743, 12.171, -31.426),

    # Effects for forbidden zones in doorways [13-24]
    vect(12.505, 5.485, -40.846),
    vect(22.609, 6.314, -45.045),
    vect(20.011, 6.314, -40.406),
    vect(35.156, 7.335, -73.588),
    vect(38.782, 6.526, -58.722),
    vect(42.152, 6.553, -49.632),
    vect(23.027, 11.884, -89.054),
    vect(78.467, 14.036, -56.311),
    vect(100.524, 14.045, -66.87),
    vect(89.352, 22.145, -62.564),
    vect(107.37, 12.166, -33.617),
    vect(87.614, 14.166, -29.335),

    # Large zones that teleport the player away from themselves if the player manages to pass through a forbidden doorway [25-30]
    vect(13.044, 9.697, -73.344),
    vect(52.662, 9.768, -31.962),
    vect(59.416, 19.498, -77.513),
    vect(95.991, 12.171, -38.315),
    vect(104.593, 16, -22.372),
    vect(89.614, 18, -19.296),

    # Places where players are teleported to if players try to enter forbidden areas [31-36]
    vect(13.466, 4.35, -34.792),
    vect(27.294, 6.507, -25.489),
    vect(25.171, 6.554, -64.938),
    vect(76.454, 14.112, -65.339),
    vect(106.979, 12.171, -37.458),
    vect(86.536, 14.171, -37.365),

    # Shop [37-48]
    vect(113.354, 16.189, -29.761), # Exit shop teleport to
    vect(97.513, 16.972, -20.29), # Connect shop
    vect(90.42, 17.169, -17.775), # Arrow to shop connector
    vect(-8.216, 10.262, -76.205), # Exit shop text
    vect(-11.251, 6.5, -87.359), # No exit shop text
    vect(112.572, 10.034, -30.484), # Shop activator
    vect(123.312, 9.176, -27.364), # ENTER_SHOP_TELEPORT_FROM
    vect(-16.309, 8.115, -89.008), # ENTER_SHOP_TELEPORT_TO
    vect(-8.2, 10.2, -76.2), # EXIT_SHOP_TELEPORT_FROM
    vect(-20.695, 7.574, -86.552), # SHOP_HEAL_AREA
    vect(123.312, 10.5, -27.364), # SHOP_TELEPORTER_TEXT
    vect(123.312, 9.176, -27.364), # SHOP_TELEPORTER_RING

    # Buy hero stats [49-53]
    vect(-31.204, 7.849, -87.474), # BUY_HP
    vect(-26.235, 7.812, -90.938), # BUY_DAMAGE
    vect(-27.198, 7.849, -96.303), # BUY_HEALING

    vect(74.955, 13.858, -52.677), # BUY_TEAM_ARMOR
    vect(75.589, 13.865, -50.533) # BUY_TEAM_SHIELDS
  ])
  vectList = decompressVectors(B)
  B = null

  enum vectListI:
    BUY_LOCATION_A = 0
    BUY_LOCATION_B = 1
    BUY_LOCATION_C = 2
    BUY_LOCATION_D = 3

    EXIT_SHOP_TELEPORT_TO = 37
    CONNECT_SHOP = 38
    CONNECT_SHOP_ARROW = 39
    EXIT_SHOP_TEXT = 40
    NO_EXIT_SHOP_TEXT = 41
    SHOP_ACTIVATOR = 42
    ENTER_SHOP_TELEPORT_FROM = 43
    ENTER_SHOP_TELEPORT_TO = 44
    EXIT_SHOP_TELEPORT_FROM = 45
    SHOP_HEAL_AREA = 46
    SHOP_TELEPORTER_TEXT = 47
    SHOP_TELEPORTER_RING = 48

    BUY_HP = 49
    BUY_DAMAGE = 50
    BUY_HEALING = 51
    BUY_TEAM_ARMOR = 52
    BUY_TEAM_SHIELDS = 53