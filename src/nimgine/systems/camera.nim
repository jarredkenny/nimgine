import math
import strformat
import opengl
import glm

import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem()
var width, height: float
var lastMouseX, lastMouseY: int

const speed = 20.0

cameraSystem.matchComponent(Position)
cameraSystem.matchComponent(ControlledCamera)

cameraSystem.subscribe(@[Resize, MouseMove,
    EventType.ZoomIn, EventType.ZoomOut])

cameraSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =
  var camera = app.scene.camera

  case event.kind:
    of Resize:
      width = event.width.float
      height = event.height.float
      app.scene.setCameraPosition(width, height)
    of ZoomIn:
      camera.zoom += dt * speed * 10
    of ZoomOut:
      camera.zoom -= dt * speed * 10
    of MouseMove:
      let dx = lastMouseX - event.x
      let dy = lastMousey - event.y
      camera.pitch -= dy.float * dt * speed * 3
      camera.angle -= dx.float * dt * speed * 3
      lastMouseX = event.x
      lastMouseY = event.y
    else:
      discard

cameraSystem.update = proc(app: Application, system: System, dt: float) =
  var camera = app.scene.camera

  let dh = camera.zoom * cos(radians(camera.pitch))
  let dv = camera.zoom * sin(radians(camera.pitch))

  let theta = camera.angle
  let offsetX = dh * sin(radians(theta))
  let offsetZ = dh * cos(radians(theta))

  let x = offsetX
  let y = dv
  let z = offsetZ


  camera.view = rotate(
    lookAt(
      vec3(x, y, z),
      vec3(0.GLfloat, 0, 0),
      vec3(0.GLfloat, 1, 0)
    ),
    radians(180 - theta),
    vec3(0.GLfloat, 1, 0)
  )
