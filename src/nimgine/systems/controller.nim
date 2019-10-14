import ../ecs
import ../events
import ../components

var controllerSystem* = newSystem()

controllerSystem.subscribe(@[
    MoveUp, MoveDown, MoveLeft, MoveRight
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Position)

controllerSystem.update = proc(world: World, system: System, event: Event, dt: float) =
    for entity in world.entitiesForSystem(system):
        var position = entity.get(Position)
        case event.kind:
            of MoveUp: position.y += 1.0
            of MoveDown: position.y -= 1.0
            of MoveLeft: position.x -= 1.0
            of MoveRight: position.x += 1.0
            else: discard
