import platform
import timing
import events
import ecs
import renderer

include systems/[input, controller, render]

var clock: Clock = newClock()

var running: bool = true

proc handle(evt: Event) =
  if evt.kind == Quit:
    running = false

proc init*() =
  platform.init()
  ecs.init()
  while running:
    queueEvent(Update)
    clock.update()
    platform.update()
    for event in pollEvent():
      handle(event)
      ecs.update(event, clock.dt)
    ecs.preRender()
    platform.preRender()
    ecs.render()
    platform.render()
