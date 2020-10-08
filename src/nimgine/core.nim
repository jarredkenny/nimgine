import strformat, os, sequtils

import types
import logger
import platform
import ui
import timing
import events
import ecs
import renderer
import debug

import systems/[input, render, camera, controller]

proc newApplication*(): Application = Application(
  world: newWorld(),
  scene: newScene(),
  clock: newClock(),
  bus: newEventQueue(),
  logger: newLogger(LogLevel.Info),
  layers: @[
    PlatformLayer,
    UILayer,
    WorldLayer,
    RendererLayer,
    DebugLayer,
  ]
)

proc init(app: Application) =
  app.logger.log("Initialization application")
  echo "Initializing Application"
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
  echo "Application Loop Starting"

  while app.running:

    while app.clock.isFirstInFrame or app.clock.dtRender < 1.0/60.0:

      # Poll Events
      for i in countdown(app.layers.len - 1, 0):
        let layer = app.layers[i]
        if layer.poll != nil and (app.clock.isFirstInFrame or layer.syncToFrame == app.clock.isFirstInFrame):
          layer.poll(app)

      # Handle Events
      for event in app.bus.pollEvent():
        app.logger.log($event)
        app.handle(event)

      # Update layer state
      for layer in app.layers:
        if layer.update != nil and (app.clock.isFirstInFrame or layer.syncToFrame == app.clock.isFirstInFrame):
          layer.update(app)

      update(app.clock)

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

    render(app.clock)


proc destroy(app: Application) =
  for layer in app.layers:
    if layer.destroy != nil:
      layer.destroy(app)

proc start*(app: Application) =
  app.running = true
  app.init()
  app.loop()
  app.destroy()
