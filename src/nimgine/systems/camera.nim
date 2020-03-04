import ../types
import ../ecs
import ../renderer

var cameraSystem* = newSystem()
var width, height: float


cameraSystem.matchComponent(ControlledCamera)
cameraSystem.matchComponent(Position)

cameraSystem.subscribe(Resize)

cameraSystem.handle = proc(app: Application, system: System, event: Event) =
  width = event.width.float
  height = event.height.float
  app.scene.setCameraPosition(width, height)

cameraSystem.preRender = proc(scene: Scene, world: World) =
  for entity in world.entitiesForSystem(cameraSystem):
    var p = entity.get(Position)
    # scene.setCameraPosition(width, height)
