import strformat, deques, glm

import types, ui, logger

import renderer/mesh

var DebugLayer* = ApplicationLayer(syncToFrame: true)

var
  debugWindow: UIWindow
  logWindow: UIWindow
  logConsole: UIElement
  consoleWindow: UIWindow
  consoleElement: UIElement

DebugLayer.init = proc(app: Application) =

  # Create Windows
  debugWindow = UIWindow(name: "Debug", open: true)
  logWindow = UIWindow(name: "Logs", open: true)
  logConsole = newUIConsole(1000)
  consoleWindow = UIWindow(name: "Console", open: true)
  consoleElement = newUIConsole(100)

  # Add Windows to Application
  app.windows.add(debugWindow)
  app.windows.add(logWindow)
  app.windows.add(consoleWindow)

DebugLayer.poll = proc(app: Application) =
  debugWindow.push(newUIText(fmt"cam x:{app.scene.camera.position.x}"))
  debugWindow.push(newUIText(fmt"cam y:{app.scene.camera.position.y}"))
  debugWindow.push(newUIText(fmt"cam z:{app.scene.camera.position.z}"))
  debugWindow.push(newUIText(fmt"Event queue: {len(app.bus.queue)}"))
  debugWindow.push(newUIText(fmt"Log queue: {len(app.logger.queue)}"))
  debugWindow.push(newUIText(fmt"Entities: {len(app.world.entities)}"))
  debugWindow.push(newUIText(fmt"Models: {modelCount}"))
  debugWindow.push(newUIText(fmt"Meshes: {meshCount}"))
  debugWindow.push(newUIText(fmt"Draw Calls: {drawCalls}"))

DebugLayer.update = proc(app: Application) =

  # Construct debug window
  debugWindow.push(newUIText(fmt"FPS: {app.clock.fps.int}"))

  # Construc log window
  logWindow.push(logConsole)

  # Construct console window
  consoleWindow.push(consoleElement)

  for line in app.logger.drain():
    logConsole.write(line)

  var footer = newUIRow(@[
    newUIInput(proc (e: UIElement) =
    case e.kind:
      of UIInput:
        consoleElement.write(fmt"> {e.buffer}")
      else:
        discard
  ),
    newUIButton("Clear"),
    newUIButton("Other")
  ])

  consoleWindow.push(footer)
