import strformat
import opengl
import glm

import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem()
var width, height: float

cameraSystem.matchComponent(Position)
cameraSystem.matchComponent(ControlledCamera)

cameraSystem.subscribe(@[Resize, MoveUp, MoveDown, MoveLeft, MoveRight,
    EventType.ZoomIn, EventType.ZoomOut])

cameraSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =

  if event.kind == Resize:
    width = event.width.float
    height = event.height.float
    app.scene.setCameraPosition(width, height)
    return

  for entity in app.world.entitiesForSystem(cameraSystem):
    var position = entity.get(Position)
    var speed_move = 15.0
    var speed_zoom = 20.0
    case event.kind:
      of MoveUp:
        position.y += speed_move * dt
      of MoveDown:
        position.y -= speed_move * dt
      of MoveLeft:
        position.x -= speed_move * dt
      of MoveRight:
        position.x += speed_move * dt
      of ZoomIn:
        position.z += speed_zoom * dt
      of ZoomOut:
        position.z -= speed_zoom * dt
      else:
        discard

    app.scene.camera.position = vec3(
      position.x.GLfloat,
      position.y.GLfloat,
      position.z.GLfloat
    )

    echo fmt"x: {position.x} y: {position.y} z: {position.z}"
