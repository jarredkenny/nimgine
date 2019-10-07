import platform
import clock
import events
import ecs

var worlds: seq[World] = @[]
var gClock: Clock = newClock()

var running: bool = true

proc init() =
  platform.init()
  for world in worlds:
    world.init()

proc update() =
  gClock.update()
  platform.update()

  for event in events.pollEvent():
    if event == Event.Quit:
      running = false
    for world in worlds:
      world.update(event, gClock.dt)

proc render() =
  platform.render()
  for world in worlds:
    world.render()

proc loop() =
  while running:
    update()
    render()

proc initGame*() =

  var world = newWorld()
  worlds.add(world)

  var e1 = newEntity()
  var c1 = newComponent()
  var s1 = newSystem()

  e1.add(c1)
  world.add(e1)
  world.add(s1)

  init()
  loop()
