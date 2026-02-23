#!mainFile "../main.opy"

#!define createVectors() __script__("create vectors.js")

globalvar vectList = compressed([
  createVectors()
])

#!define VL_BUY_HERO_SPOTS_LEN (VL_BUY_HERO_SPOTS_A_LEN + VL_BUY_HERO_SPOTS_B_LEN + VL_BUY_HERO_SPOTS_E_LEN + VL_BUY_HERO_SPOTS_I_LEN + VL_BUY_HERO_SPOTS_H_LEN)
