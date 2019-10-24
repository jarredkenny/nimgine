import types
import platform
import ui
import timing
import events
import ecs
import renderer

import systems/[input, controller, render, camera, gui]

proc newApplication*(): Application = Application(
  world: newWorld(),
  scene: newScene(),
  clock: newClock(),
  layers: @[
    PlatformLayer,
    UILayer,
    WorldLayer,
    RendererLayer
  ]
)

proc init(app: Application) =
  app.world.add(@[
    guiSystem,
    cameraSystem,
    controllerSystem,
    inputSystem,
    renderSystem
  ])
  for layer in app.layers:
    if layer.init != nil:
      layer.init(app)

proc handle(app: Application, event: Event) =
  for layer in app.layers:
    if layer.handle != nil:
      layer.handle(app, event)
      if event.handled:
        break

proc loop(app: Application) =
  while app.running:

    # Update
    queueEvent(Update)

    update(app.clock)

    for layer in app.layers:
      if layer.update != nil:
        layer.update(app)

    # Handle Events
    for event in pollEvent():
      echo(event)
      app.handle(event)

    # Pre-Render
    for i in countdown(app.layers.len - 1, 0):
      let layer = app.layers[i]
      if layer.preRender != nil:
        layer.preRender(app)

    # Render
    for i in countdown(app.layers.len - 1, 0):
      let layer = app.layers[i]
      if layer.render != nil:
        layer.render(app)


proc start*(app: Application) =
  app.running = true
  app.init()
  app.loop()
