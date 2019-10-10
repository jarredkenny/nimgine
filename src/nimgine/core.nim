import platform
import timing
import events
import ecs
import input

var clock: Clock = newClock()
var inputManager = newInputManager()
var running: bool = true

proc init() =
  ecs.init()
  platform.init()

proc update() =
  queueEvent(Update)
  clock.update()
  platform.update()
  for event in pollEvent():

    if event.kind == Input:
      inputManager.inputs[event.input] = event.state


    ecs.update(event, clock.dt)
    if event.kind == Quit:
      running = false

proc render() =
  queueEvent(Render)
  ecs.render()
  platform.render()

proc loop() =
  while running:
    update()
    render()

proc initGame*() =
  init()
  loop()
