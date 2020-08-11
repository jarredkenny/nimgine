import glm

import ../types
import ../ecs

var controllerSystem* = newSystem()

controllerSystem.subscribe(@[
    MoveForward, MoveBackward, MoveLeft, MoveRight, EventType.ZoomIn, EventType.ZoomOut, PanUp, PanDown, PanLeft, PanRight
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Position)
controllerSystem.matchComponent(Orientation)
controllerSystem.matchComponent(Camera)

controllerSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =
    echo "controller system event: " & $event.kind
    for entity in app.world.entitiesForSystem(controllerSystem):
        var position = entity.get(Position)
        var orientation = entity.get(Orientation)

        var velocity = 1.0 * dt;
        var pos = vec3(position.x, position.y, position.z)


        case event.kind:
            of EventType.MoveForward:
                position.y += 0.01
            of EventType.MoveBackward:
                position.y -= 0.01
            of EventType.MoveLeft:
                position.x -= 0.01
            of EventType.MoveRight:
                position.x += 0.01
            of EventType.ZoomIn:
                position.z -= 0.4
            of EventType.ZoomOut:
                position.z += 0.4
            of EventType.PanUp:
                orientation.pitch -= 1
            of EventType.PanDown:
                orientation.pitch += 1
            of EventType.Panleft:
                orientation.yaw -= 1
            of EventType.PanRight:
                orientation.yaw += 1
            else: discard
