import platform
import timing
import events
import ecs

include systems/[input, controller, renderer]

var clock: Clock = newClock()
var running: bool = true

proc update() =
  queueEvent(Update)
  clock.update()
  platform.update()
  for event in pollEvent():
    ecs.update(event, clock.dt)
    if event.kind == Quit:
      running = false

proc preRender() =
  ecs.preRender()
  platform.preRender()

proc render() =
  ecs.render()
  platform.render()

proc loop() =
  while running:
    update()
    preRender()
    render()

proc init*() =
  ecs.init()
  platform.init()
  loop()
