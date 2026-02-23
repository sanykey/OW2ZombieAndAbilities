let result = "";

const vectors = [
  { // Effects for purchase access to locked areas [0-3] len =4
    list: [
      ["vect(7.613, 5.326, -34.916)", "VL_BUY_LOCATION_A"],
      ["vect(31.577, 6.126, -62.399)", "VL_BUY_LOCATION_B"],
      ["vect(99.296, 13.977, -72.064)", "VL_BUY_LOCATION_C"],
      ["vect(86.651, 14.036, -32.931)", "VL_BUY_LOCATION_D"],
    ]
  },

  { // Areas in doorways that push away approaching players when the doorway is not yet open [4-12] len = 9
    list: [
      "vect(19, 7, -50.013)",
      "vect(40.631, 8.265, -77.59)",
      "vect(51.561, 8.095, -58.373)",
      "vect(23.088, 12.063, -89.42)",
      "vect(78.65, 14.171, -53.779)",
      "vect(103.219, 15.554, -60.019)",
      "vect(91.888, 22.491, -53.112)",
      "vect(87.651, 15, -28.387)",
      "vect(107.743, 12.171, -31.426)",
    ]
  },

  { // Effects for forbidden zones in doorways [13-24], len = 12 (LOCKED_AREA_EFFECTS_LEN).
    offset: "VL_LOCKED_AREA_EFFECTS_OFFSET",
    len: "VL_LOCKED_AREA_EFFECTS_LEN",
    list: [
      "vect(12.505, 5.485, -40.846)",
      "vect(22.609, 6.314, -45.045)",
      "vect(20.011, 6.314, -40.406)",
      "vect(35.156, 7.335, -73.588)",
      "vect(38.782, 6.526, -58.722)",
      "vect(42.152, 6.553, -49.632)",
      "vect(23.027, 11.884, -89.054)",
      "vect(78.467, 14.036, -56.311)",
      "vect(100.524, 14.045, -66.87)",
      "vect(89.352, 22.145, -62.564)",
      "vect(107.37, 12.166, -33.617)",
      "vect(87.614, 14.166, -29.335)",
    ],
  },

  { // Large zones that teleport the player away from themselves if the player manages to pass through a forbidden doorway [25-30] len = 6
    list: [
      "vect(13.044, 9.697, -73.344)",
      "vect(52.662, 9.768, -31.962)",
      "vect(59.416, 19.498, -77.513)",
      "vect(95.991, 12.171, -38.315)",
      "vect(104.593, 16, -22.372)",
      "vect(89.614, 18, -19.296)",
    ]
  },

  { // Places where players are teleported to if players try to enter forbidden areas [31-36] len = 6
    list: [
      "vect(13.466, 4.35, -34.792)",
      "vect(27.294, 6.507, -25.489)",
      "vect(25.171, 6.554, -64.938)",
      "vect(76.454, 14.112, -65.339)",
      "vect(106.979, 12.171, -37.458)",
      "vect(86.536, 14.171, -37.365)",
    ]
  },

  // [Secret shop]
  { 
    offset: "VL_SECRET_SHOP_OFFSET",
    len: "VL_SECRET_SHOP_LEN", 
    list: [
      ["vect(113.354, 16.189, -29.761)", "VL_EXIT_SHOP_TELEPORT_TO"],
      ["vect(97.513, 16.972, -20.29)", "VL_CONNECT_SHOP"],
      ["vect(90.42, 17.169, -17.775)", "VL_CONNECT_SHOP_ARROW"],
      ["vect(-8.216, 10.262, -76.205)", "VL_EXIT_SHOP_TEXT"],
      ["vect(-11.251, 6.5, -87.359)", "VL_NO_EXIT_SHOP_TEXT"],
      ["vect(112.572, 10.034, -30.484)", "VL_SHOP_ACTIVATOR"],
      ["vect(123.312, 9.176, -27.364)", "VL_ENTER_SHOP_TELEPORT_FROM"],
      ["vect(-16.309, 8.115, -89.008)", "VL_ENTER_SHOP_TELEPORT_TO"],
      ["vect(-8.2, 10.2, -76.2)", "VL_EXIT_SHOP_TELEPORT_FROM"],
      ["vect(123.312, 10.5, -27.364)", "VL_SHOP_TELEPORTER_TEXT"],
      ["vect(123.312, 9.176, -27.364)", "VL_SHOP_TELEPORTER_RING"],
      ["vect(-30.87, 12.00, -91.50)", "VL_SHOP_TIP"],
      ["vect(-19.91, 6.50, -93.88)", "VL_REFUND"],
      ["vect(-11.54, 11.30, -76.66)", "VL_SHOP_ZONE2"],
    ]
  },

  // Buy hero upgrades
  {
    offset: "VL_BUY_UPRADES_OFFSET",
    len: "VL_BUY_UPRADES_LEN", 
    list: [
      ["vect(-31.204, 7.8, -87.474)", "VL_BUY_HP"],
      ["vect(-26.235, 7.8, -90.938)", "VL_BUY_DAMAGE"],
      ["vect(-27.198, 7.8, -96.303)", "VL_BUY_HEALING"],
      ["vect(-27.94, 7.8, -85.89)", "VL_BUY_TEAM_ARMOR"],
      ["vect(-21.08, 7.8, -82.96)", "VL_CHANGE_HERO"],
    ]
  },

  // Hero buy spots, zone A
  {
    offset: "VL_BUY_HERO_SPOTS_OFFSET",
    len: "VL_BUY_HERO_SPOTS_A_LEN", 
    list: [
      "vect(-18.268, 0.50, -10.4)", // Baby DVA
      "vect(-2.191, 2.50, -38.067)",
      "vect(26.385, 4.51, -32.792)",
      "vect(14.038, 4.52, -18.487)",
      "vect(27.171, 1.43, -12.287)",
      "vect(-4.685, 0.50, -8.427)",
      "vect(-16.322, 2.50, -31.226)",
    ]
  },

  // Hero buy spots, zone B
  {
    len: "VL_BUY_HERO_SPOTS_B_LEN", 
    list: [
      "vect(12.129, 6.51, -90.424)",
      "vect(10.56, 11.5, -84.54)",
      "vect(12.919, 11.51, -100.131)",
      "vect(12.823, 6.5, -57.833)",
      "vect(1.675, 6.5, -47.434)",
      "vect(-0.898, 4.69, -90.515)",
      "vect(-1.751, 7, -71.73)",
      "vect(-7.94, 4, -83.07)",
    ]
  },

  // Hero buy spots, zone E
  {
    len: "VL_BUY_HERO_SPOTS_E_LEN", 
    list: [
      "vect(59.56, 7.22, -72.899)",
      "vect(55.848, 12.25, -78.688)",
      "vect(53.699, 18.54, -80.776)",
      "vect(58.868, 5.22, -91.486)",
      "vect(80.335, 13.18, -72.643)",
      "vect(79.002, 11.15, -110.348)", 
      "vect(56.188, 18.22, -110.215)",
      "vect(33.25, 10.52, -93.513)",
      "vect(36.879, 13.22, -105.779)",
      "vect(54.407, 21.5, -67.496)",
      "vect(102.662, 10.07, -91.232)",
      "vect(60.62, 7.22, -108.23)",
    ]
  },

  // Hero buy spots, zone I
  {
    len: "VL_BUY_HERO_SPOTS_I_LEN", 
    list: [
      "vect(122.079, 11.22, -64.267)",
      "vect(108.546, 13.22, -55.139)",
      "vect(129.875, 15.24, -36.803)",
      "vect(142.02, 12.22, -43.53)",
      "vect(136.33, 12.22, -62.21)",
      "vect(138.12, 12.22, -55.53)",
      "vect(142.26, 12.22, -39.43)",
      "vect(111.64, 13.22, -59.40)",
    ]
  },

  // Hero buy spots, zone H
  {
    len: "VL_BUY_HERO_SPOTS_H_LEN", 
    list: [
      "vect(132.44, 11.22, 7.48)",
      "vect(129.50, 11.22, 8.29)",
      "vect(126.59, 11.22, 9.00)",
      "vect(135.33, 11.22, 6.72)",
      "vect(138.23, 11.22, 5.93)",
      "vect(141.17, 11.22, 5.25)",
      "vect(123.66, 11.22, 9.80)",
      "vect(130.42, 11.22, -0.26)",
      "vect(133.33, 11.22, -1.04)",
      "vect(127.75, 11.22, 0.40)",
    ]
  },

  // Map zones
  {
    offset: "VL_ACTIVATE_ZONES_OFFSET",
    len: "VL_ACTIVATE_ZONES_LEN", 
    list: [
      ["vect(-6.965, 2.94, -7.146)", "VL_ACTIVATE_ZONE_DETECTOR_A"],
      ["vect(13.044, 9.697, -73.344)", "VL_ACTIVATE_ZONE_DETECTOR_B"],
      ["vect(-23.86, 8.08, -89.854)", "VL_ACTIVATE_ZONE_DETECTOR_C"],
      ["vect(59.416, 19.498, -77.513)", "VL_ACTIVATE_ZONE_DETECTOR_D"],
      ["vect(75.315, 22.594, -101.637)", "VL_ACTIVATE_ZONE_DETECTOR_E"],
      ["vect(108.196, 14.309, -22.096)", "VL_ACTIVATE_ZONE_DETECTOR_F"],
      ["vect(140.011, 12.178, -61.257)", "VL_ACTIVATE_ZONE_DETECTOR_G"],
      ["vect(144.10, 10.36, 31.35)", "VL_ACTIVATE_ZONE_DETECTOR_H"],
      ["vect(129.36, 11.72, -49.72)", "VL_ACTIVATE_ZONE_DETECTOR_I"]
    ]
  },

  {
    offset: "VL_BOT_SNIPER_SPOTS_OFFSET",
    len: "VL_BOT_SNIPER_SPOTS_LEN", 
    list: [
      "vect(-2.91, 5.20, -13.38)",
      "vect(15.42, 6.25, -30.04)",
      "vect(13.33, 11.61, -42.38)",
      "vect(13.86, 12.56, -82.01)",
      "vect(22.09, 12.30, -73.98)",
      "vect(32.08, 8.79, -48.16)",
      "vect(33.31, 14.89, -85.18)",
      "vect(56.24, 23.98, -103.35)",
      "vect(50.73, 19.47, -78.32)",
      "vect(98.86, 19.71, -72.58)",
      "vect(89.35, 22.09, -62.54)",
      "vect(81.28, 17.02, -38.14)",
      "vect(117.72, 20.17, -42.66)",
      "vect(125.06, 16.04, -19.54)",
      "vect(110.83, 14.02, -47.27)",
    ]
  },
];

let vectIndex = 0
vectors.forEach(item => {
  result += `\n\n`

  if (item.offset) {
    result += `  #!define ${item.offset} ${vectIndex}\n`
  }

  let currentLen = 0
  item.list.forEach((item) => {
    if (item instanceof Array) {
      result += `  ${item[0]},\n  #!define ${item[1]} ${vectIndex}\n`
    } else {
      result += `  ${item},\n`
    }
    vectIndex += 1;
    currentLen += 1;
  });
  if (item.len) {
    result += `  #!define ${item.len} ${currentLen}\n`
  }
});

result