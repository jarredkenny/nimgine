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

  entityWindow: UIWindow

  terrainRenderDistance*: float32 = 10
  terrainSize*: float32 = 10.0
  terrainDensity*: float32 = 50.0
  terrainOctaves*: float32 = 4.0
  terrainAmp*: float32 = 10.0
  terrainSpreadX*: float32 = 50.0
  terrainSpreadZ*: float32 = 50.0
  terrainPersistence*: float32 = 0.2

DebugLayer.init = proc(app: Application) =

  # Create Windows
  debugWindow = UIWindow(name: "Debug", open: true)
  logWindow = UIWindow(name: "Logs", open: false)
  logConsole = newUIConsole(1000)
  consoleWindow = UIWindow(name: "Console", open: false)
  consoleElement = newUIConsole(100)
  terrainWindow = UIWindow(name: "Terrain", open: true)
  entityWindow = UIWindow(name: "Entity Manager", open: true)
  
  # Add Windows to Application
  app.windows.add(debugWindow)
  app.windows.add(logWindow)
  app.windows.add(consoleWindow)
  app.windows.add(terrainWindow)
  app.windows.add(entityWindow)

DebugLayer.poll = proc(app: Application) =
  discard
  # debugWindow.push(newUIText(fmt"viewer x:{app.world.viewer.translation.x}"))
  # debugWindow.push(newUIText(fmt"viewer y:{app.world.viewer.translation.y}"))
  # debugWindow.push(newUIText(fmt"viewer z:{app.world.viewer.translation.z}"))
  # debugWindow.push(newUIText(fmt"cam yaw:{app.scene.camera.rotation.x}"))
  # debugWindow.push(newUIText(fmt"cam pitch:{app.scene.camera.rotation.y}"))
  # debugWindow.push(newUIText(fmt"cam roll:{app.scene.camera.rotation.z}"))
  # debugWindow.push(newUIText(fmt"render mode: {app.scene.renderMode}"))
  # debugWindow.push(newUIText(fmt"Event queue: {len(app.bus.queue)}"))
  # debugWindow.push(newUIText(fmt"Log queue: {len(app.logger.queue)}"))
  # debugWindow.push(newUIText(fmt"Entities: {len(app.world.entities)}"))
  # debugWindow.push(newUIText(fmt"Models: {modelCount}"))
  # debugWindow.push(newUIText(fmt"Meshes: {meshCount}"))
  # debugWindow.push(newUIText(fmt"Draw Calls: {drawCalls}"))


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

  # entityWindow.push(newUIEntityTree(app.world.entities))

  # # Construct Terrain Window

  # terrainWindow.push(newUISlider("Distance", terrainRenderDistance.addr, 1.float32, 32.0.float32))
  # terrainWindow.push(newUISlider("Size", terrainSize.addr, 32.float32, 256.float32))
  # terrainWindow.push(newUISlider("Density", terrainDensity.addr, 1.float32, 1000.0.float32))
  # terrainWindow.push(newUISlider("Octaves", terrainOctaves.addr, 1.float32, 10.0.float32))
  # terrainWindow.push(newUISlider("Amplitide",  terrainAmp.addr, 1.float32, 1000.0.float32))
  # terrainWindow.push(newUISlider("Spread X", terrainSpreadX.addr, 1.float32, 1000.0.float32))
  # terrainWindow.push(newUISlider("Spread Z", terrainSpreadZ.addr, 1.float32, 1000.0.float32))
  # terrainWindow.push(newUISlider("Persistance", terrainPersistence.addr, 0.float32, 1.0.float32))

