import ../types
import ../ecs

var controllerSystem* = newSystem()

controllerSystem.subscribe(@[
    MoveUp, MoveDown, MoveLeft, MoveRight, EventType.ZoomIn, EventType.ZoomOut
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Position)

controllerSystem.handle = proc(app: Application, system: System, event: Event) =
    for entity in app.world.entitiesForSystem(controllerSystem):
        var position = entity.get(Position)
        case event.kind:
            of EventType.MoveUp:
                position.y += 0.1
            of EventType.MoveDown:
                position.y -= 0.1
            of EventType.MoveLeft:
                position.x -= 0.1
            of EventType.MoveRight:
                position.x += 0.1
            of EventType.ZoomIn:
                position.z -= 0.1
            of EventType.ZoomOut:
                position.z += 0.1
            else: discard
