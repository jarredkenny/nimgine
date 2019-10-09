import times

type
  Clock* = object
    dt*: float
    fps*: float
    timer*: float
    ticks*: int
    last*: float

proc newClock*(): Clock =
  result = Clock(
    dt: 0.0,
    fps: 0.0,
    timer: 0.0,
    last: 0.0,
    ticks: 0
  )

proc update*(clock: var Clock) =
  var now = cpuTime()
  clock.dt = (now - clock.last)
  clock.last = now
  clock.fps = (if clock.dt == 0.0: 0.0 else: (1.0 / clock.dt))
  clock.timer += clock.dt
  inc(clock.ticks)
