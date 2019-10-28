import types
import platform
import ui
import timing
import events
import ecs
import renderer
import debug

import systems/[input, controller, render, camera]

proc newApplication*(): Application = Application(
  world: newWorld(),
  scene: newScene(),
  clock: newClock(),
  bus: newEventQueue(),
  layers: @[
    PlatformLayer,
    DebugLayer,
    UILayer,
    WorldLayer,
    RendererLayer
  ]
)

proc init(app: Application) =
  app.world.add(@[
    cameraSystem,
    controllerSystem,
    inputSystem,
    renderSystem
  ])
  for layer in app.layers:
    if layer.init != nil:
      layer.init(app)

proc handle(app: Application, event: Event) =
  if event.kind == EventType.Quit:
    app.running = false
  for layer in app.layers:
    if layer.handle != nil:
      layer.handle(app, event)
      if event.handled:
        break

proc loop(app: Application) =
  while app.running:

    # Poll Events
    for i in countdown(app.layers.len - 1, 0):
      let layer = app.layers[i]
      if layer.poll != nil:
        layer.poll(app)

    # Handle Events
    for event in pollEvent():
      app.handle(event)

    # Update
    update(app.clock)

    # Update layer state
    for layer in app.layers:
      if layer.update != nil:
        layer.update(app)

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

proc destroy(app: Application) =
  for layer in app.layers:
    if layer.destroy != nil:
      layer.destroy(app)

proc start*(app: Application) =
  app.running = true
  app.init()
  app.loop()
  app.destroy()
