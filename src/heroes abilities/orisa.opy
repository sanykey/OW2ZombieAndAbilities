#!mainFile "../main.opy"


rule "[Orisa] Orisa gains a health pool when another player attaches to her":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.attach2p[Attach2P.CHILD]
  
  eventPlayer.addHealthPool(Health.NORMAL, eventPlayer.attach2p[Attach2P.CHILD].getMaxHealth() / 4, true, false)
  eventPlayer.attach2p[Attach2P.HEALTH_POOL] = getLastCreatedHealthPool()

  waitUntil(not entityExists(eventPlayer.attach2p[Attach2P.CHILD]), INFINITY)
  removeHealthPool(eventPlayer.attach2p[Attach2P.HEALTH_POOL])
  eventPlayer.attach2p = []