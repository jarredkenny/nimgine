import strformat, deques

import types, ui, logger, events

var DebugLayer* = ApplicationLayer(syncToFrame: true)

var
  debugWindow: UIWindow
  consoleWindow: UIWindow
  consoleElement: UIElement

DebugLayer.init = proc(app: Application) =

  # Create Windows
  debugWindow = UIWindow(name: "Debug", open: true)
  consoleWindow = UIWindow(name: "Console", open: true)
  consoleElement = newUIConsole(100)

  # Add Windows to Application
  app.windows.add(debugWindow)
  app.windows.add(consoleWindow)

DebugLayer.poll = proc(app: Application) =
  debugWindow.push(newUIText(fmt"App event queue: {len(app.bus.queue)}"))
  debugWindow.push(newUIText(fmt"Log event queue: {len(app.logger.queue)}"))

DebugLayer.update = proc(app: Application) =

  # Construct debug window
  debugWindow.push(newUIText(fmt"FPS: {app.clock.fps.int}"))

  # Construct console window
  consoleWindow.push(consoleElement)

  for line in app.logger.drain():

    consoleElement.write(line)

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