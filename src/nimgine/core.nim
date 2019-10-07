import platform
import events

proc init() =
  platform.init()

proc loop() =
  var running = true
  while running:
    platform.update()
    platform.render()
    for event in events.pollEvent():
      if event == Event.Quit:
        running = false

init()
loop()
