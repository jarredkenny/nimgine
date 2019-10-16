import ../ecs
import ../renderer
import ../components

var cameraSystem* = newSystem()

cameraSystem.matchComponent(ControlledCamera)
cameraSystem.matchComponent(Position)

cameraSystem.preRender = proc(scene: Scene, world: World) =
  for entity in world.entitiesForSystem(cameraSystem):
    var p = entity.get(Position)
    scene.setCameraPosition(p.x, p.y, p.z)
