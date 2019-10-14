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

proc update() =
  queueEvent(Update)
  clock.update()
  platform.update()
  for event in pollEvent():
    handle(event)
    ecs.update(event, clock.dt)

proc preRender() =
  ecs.preRender()
  platform.preRender()
  renderer.preRender()

proc render() =
  ecs.render()
  platform.render()


proc init*() =
  platform.init()
  ecs.init()
  while running:
    update()
    preRender()
    render()
