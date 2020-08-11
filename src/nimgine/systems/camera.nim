import math
import strformat
import opengl
import glm

import ../types
import ../ecs
import ../renderer
import ../logger

var cameraSystem* = newSystem()

cameraSystem.matchComponent(Position)
cameraSystem.matchComponent(Camera)

cameraSystem.subscribe(@[Resize, MouseMove,
    EventType.ZoomIn, EventType.ZoomOut])

cameraSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =
  case event.kind:
    of EventType.Resize:
      app.scene.setCameraDimensions(event.width, event.height)
    else:
      discard

cameraSystem.preRender = proc(scene: Scene, world: World) =
  let entity = world.entityForSystem(cameraSystem)
  let position: Position = entity.get(Position)

  echo fmt"camera position is {position.x},{position.y},{position.z}"

  scene.setCameraPosition(vec3(position.x.GLfloat, position.y, position.z))
  scene.setCameraTargetPosition(vec3(0.GLfloat, 0, 1))