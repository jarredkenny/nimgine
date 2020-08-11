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
  let orientation: Orientation = entity.get(Orientation)
  let camera: Camera = entity.get(Camera)

  scene.setCamera(camera)
  scene.setCameraZoom(1.0)
  scene.setCameraPosition(position.x, position.y, position.z)
  scene.setCameraOrientation(orientation.yaw, orientation.pitch, orientation.roll)