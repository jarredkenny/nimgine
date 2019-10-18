import imgui

import platform
import timing
import events
import ecs
import renderer

import systems/[input, controller, render, camera]

var clock: Clock = newClock()
var scene: Scene = newScene()

var running: bool = true

proc handle(evt: Event) =
  if evt.kind == Quit:
    running = false

proc initialize(world: World) =
  platform.init()
  world.add(@[
    cameraSystem,
    controllerSystem,
    inputSystem,
    renderSystem
  ])
  world.init()

proc start*(world: World) =

  # Init World
  initialize(world)

  igCreateContext()

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
    scene.preRender(world)
    platform.preRender()
    renderer.preRender(scene)

    # Render
    scene.render(world)
    renderer.render(scene)

    platform.render()
