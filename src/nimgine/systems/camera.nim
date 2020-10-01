import math
import strformat
import opengl
import glm

import ../types
import ../ecs
import ../renderer
import ../logger

var cameraSystem* = newSystem()

cameraSystem.matchComponent(Transform)
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
  let transform: Transform = entity.get(Transform)

  echo fmt"camera position is {transform.translation.x},{transform.translation.y},{transform.translation.z}"

  scene.setCameraPosition(vec3(transform.translation.x.GLfloat,
      transform.translation.y, transform.translation.z))
  scene.setCameraTargetPosition(vec3(0.1.GLfloat, 0.1, 0.1))
