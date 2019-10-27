import types, ui

var DebugLayer* = ApplicationLayer()

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

DebugLayer.handle = proc(app: Application, event: Event) =

  # Handle Log Event
  if event.kind == EventType.Log:
    consoleElement.write(event.line)

DebugLayer.update = proc(app: Application) =

  # Construct debug window
  debugWindow.push(newUIText("FPS: " & $app.clock.fps.int))

  # Construct console window
  consoleWindow.push(consoleElement)

  var footer = newUIRow(@[
    newUIInput(),
    newUIButton("Clear"),
    newUIButton("Other")
  ])

  consoleWindow.push(footer)
