import times

import types

proc newClock*(): Clock =
  result = Clock(
    ticks: 0,
    dtUpdate: 0.0,
    dtRender: 0.0,
    lastRender: 0.0,
    fps: 0,
    isFirstInFrame: true
  )

proc update*(clock: var Clock) =
  var now = cpuTime()
  var dt = now - clock.dtUpdate
  clock.dtUpdate = dt
  clock.dtRender = now - clock.lastRender
  clock.fps = (1.0 / clock.dtRender).int
  clock.ticks = clock.ticks + 1
  clock.isFirstInFrame = false

proc render*(clock: var Clock) =
  clock.lastRender = cpuTime()
  clock.isFirstInFrame = true