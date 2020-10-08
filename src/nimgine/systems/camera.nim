import strformat
import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem()

cameraSystem.matchComponent(Transform)
cameraSystem.matchComponent(Camera)

cameraSystem.subscribe(Resize)

cameraSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =
  case event.kind:
    of EventType.Resize:
      echo fmt"Setting camera dimensions: {event.width}x{event.height}"
      app.scene.setCameraDimensions(event.width, event.height)
    else:
      discard

cameraSystem.preRender = proc(scene: Scene, world: World) =
  let entity = world.entityForSystem(cameraSystem)
  let transform: Transform = entity.get(Transform)
  scene.setCameraPosition(transform)

