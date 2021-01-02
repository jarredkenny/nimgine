import strformat
import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem(false)

cameraSystem.matchComponent(Transform)
cameraSystem.matchComponent(Camera)

cameraSystem.subscribe(Resize)

cameraSystem.handle = proc(universe: Universe, system: System, event: Event, dt: float) =
  case event.kind:
    of EventType.Resize:
      universe.app.scene.setCameraDimensions(event.width, event.height)
    else:
      discard

cameraSystem.preRender = proc(universe: Universe, scene: Scene) =
  let entity = universe.entityForSystem(cameraSystem)
  # Univ: get model from entity
  # let transform: Transform = entity.get(Transform)
  # world.viewer = transform
  # scene.setCameraPosition(transform)

