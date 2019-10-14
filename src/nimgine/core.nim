import platform
import timing
import events
import ecs
import renderer

import systems/[input, controller, render]

var clock: Clock = newClock()

var running: bool = true

proc handle(evt: Event) =
  if evt.kind == Quit:
    running = false

proc initialize(world: World) =
  platform.init()
  world.add(@[
    inputSystem,
    controllerSystem,
    renderSystem
  ])
  world.init()

proc start*(world: World) =

  # Init World
  initialize(world)

  # Game Loop
  while running:

    # Update
    queueEvent(Update)
    clock.update()
    platform.update()
    for event in pollEvent():
      handle(event)
      world.update(event, clock.dt)

    # Pre-Render
    world.preRender()
    platform.preRender()
    renderer.preRender()

    # Render
    world.render()
    platform.render()
    renderer.render()
