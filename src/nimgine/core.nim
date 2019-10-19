import platform
import ui
import timing
import events
import ecs
import renderer

import systems/[input, controller, render, camera, gui]

var clock: Clock = newClock()
var scene: Scene = newScene()

var running: bool = true

proc handle(evt: Event) =
  if evt.kind == Quit:
    running = false

proc start*(world: World) =

  # Init World
  var window = platform.init()

  ui.init(window)

  world.add(@[
    guiSystem,
    cameraSystem,
    controllerSystem,
    inputSystem,
    renderSystem
  ])

  world.init()

  # Game Loop
  while running:

    # Update
    queueEvent(Update)
    clock.update()
    platform.update()
    ui.update()
    for event in pollEvent():
      handle(event)
      world.update(event, clock.dt)

    # Pre-Render
    scene.preRender(world)
    platform.preRender()
    renderer.preRender(scene)

    # Render
    scene.render(world)
    renderer.render(scene)
    ui.render()

    platform.render()
