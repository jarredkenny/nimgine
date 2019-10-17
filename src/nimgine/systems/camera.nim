import ../ecs
import ../events
import ../renderer
import ../components

var cameraSystem* = newSystem()
var aspect = 16.0 / 9.0

cameraSystem.matchComponent(ControlledCamera)
cameraSystem.matchComponent(Position)

cameraSystem.subscribe(Resize)

cameraSystem.update = proc(world: World, system: System, event: Event, dt: float) =
  aspect = event.width / event.height

cameraSystem.preRender = proc(scene: Scene, world: World) =
  for entity in world.entitiesForSystem(cameraSystem):
    var p = entity.get(Position)
    scene.setCameraPosition(p.x, p.y, p.z, aspect)
