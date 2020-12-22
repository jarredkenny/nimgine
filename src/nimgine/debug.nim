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
  terrainWindow: UIWindow

  terrainSize*, terrainDensity*, terrainAmp*: float32 = 100

DebugLayer.init = proc(app: Application) =

  # Create Windows
  debugWindow = UIWindow(name: "Debug", open: true)
  logWindow = UIWindow(name: "Logs", open: true)
  logConsole = newUIConsole(1000)
  consoleWindow = UIWindow(name: "Console", open: true)
  consoleElement = newUIConsole(100)
  terrainWindow = UIWindow(name: "Terrain", open: true)
  
  # Add Windows to Application
  app.windows.add(debugWindow)
  app.windows.add(logWindow)
  app.windows.add(consoleWindow)
  app.windows.add(terrainWindow)

DebugLayer.poll = proc(app: Application) =
  debugWindow.push(newUIText(fmt"cam x:{app.scene.camera.position.x}"))
  debugWindow.push(newUIText(fmt"cam y:{app.scene.camera.position.y}"))
  debugWindow.push(newUIText(fmt"cam z:{app.scene.camera.position.z}"))
  debugWindow.push(newUIText(fmt"cam yaw:{app.scene.camera.rotation.x}"))
  debugWindow.push(newUIText(fmt"cam pitch:{app.scene.camera.rotation.y}"))
  debugWindow.push(newUIText(fmt"cam roll:{app.scene.camera.rotation.z}"))
  debugWindow.push(newUIText(fmt"render mode: {app.scene.renderMode}"))
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

  # Construct Terrain Window
  terrainWindow.push(newUISlider("Size", terrainSize.addr, 0.0.float32, 1000.0.float32))
  terrainWindow.push(newUISlider("Density", terrainDensity.addr, 0.0.float32, 1000.0.float32))
  terrainWindow.push(newUISlider("Amplitide", terrainAmp.addr, 0.0.float32, 100.0.float32))
