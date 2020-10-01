import ../types
import ../ecs

import glm

var controllerSystem* = newSystem()

controllerSystem.subscribe(@[
    MoveUp, MoveDown, MoveLeft, MoveRight, EventType.ZoomIn, EventType.ZoomOut
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Transform)

controllerSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =
    echo "controller system event: " & $event.kind
    for entity in app.world.entitiesForSystem(controllerSystem):
        var transform = entity.get(Transform)
        case event.kind:
            of EventType.MoveUp:
                discard
            of EventType.MoveDown:
                discard
            of EventType.MoveLeft:
                discard
            of EventType.MoveRight:
                discard
            of EventType.ZoomIn:
                transform.translation += transform.rotation
                discard
            of EventType.ZoomOut:
                discard
            else:
                discard
