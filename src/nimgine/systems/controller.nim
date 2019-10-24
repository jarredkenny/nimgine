import ../types
import ../ecs

var controllerSystem* = newSystem()

controllerSystem.subscribe(@[
    MoveUp, MoveDown, MoveLeft, MoveRight, ZoomIn, ZoomOut
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Position)

controllerSystem.update = proc(world: World, system: System, event: Event, dt: float) =
    for entity in world.entitiesForSystem(controllerSystem):
        var position = entity.get(Position)
        case event.kind:
            of MoveUp:
                position.y += 0.5
            of MoveDown:
                position.y -= 0.5
            of MoveLeft:
                position.x -= 0.5
            of MoveRight:
                position.x += 0.5
            of ZoomIn:
                position.z -= 0.5
            of ZoomOut:
                position.z += 0.5
            else: discard
