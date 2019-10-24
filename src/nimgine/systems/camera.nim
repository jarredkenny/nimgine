import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem()
var aspect = 16.0 / 9.0

cameraSystem.matchComponent(ControlledCamera)
cameraSystem.matchComponent(Position)

cameraSystem.subscribe(Resize)

cameraSystem.handle = proc(world: World, system: System, event: Event) =
  aspect = event.width / event.height

cameraSystem.preRender = proc(scene: Scene, world: World) =
  for entity in world.entitiesForSystem(cameraSystem):
    var p = entity.get(Position)
    scene.setCameraPosition(p.x, p.y, p.z, aspect)
