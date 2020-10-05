import strformat, deques

import types, ui, logger, events

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
  debugWindow.push(newUIText(fmt"App event queue: {len(app.bus.queue)}"))
  debugWindow.push(newUIText(fmt"Log event queue: {len(app.logger.queue)}"))
  debugWindow.push(newUIText(fmt"Entities: {len(app.world.entities)}"))

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
