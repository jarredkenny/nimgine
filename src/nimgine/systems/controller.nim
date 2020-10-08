import ../types
import ../ecs

import glm

var controllerSystem* = newSystem(false)

controllerSystem.subscribe(@[
    MoveForward, MoveBackward, MoveLeft, MoveRight, EventType.ZoomIn, EventType.ZoomOut
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Transform)


controllerSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =

    for entity in app.world.entitiesForSystem(controllerSystem):
        var transform = entity.get(Transform)

        var front = normalize(vec3(
            cos(radians(transform.rotation.x) * cos(radians(transform.rotation.y))),
            sin(radians(transform.rotation.y)),
            sin(radians(transform.rotation.x)) * cos(radians(transform.rotation.y))
        ))

        case event.kind:
            # of EventType.MoveForward:
            #     transform.rotation += app.world.up * dt * 0.001
            # of EventType.MoveBackward:
            #     transform.rotation -= app.world.up * dt * 0.001
        
            of MoveForward:
                transform.translation += vec3(1.0.Point, 0.0, 0.0) + front * dt
            
            of MoveBackward:
                transform.translation -= vec3(1.0.Point, 0.0, 0.0) + front * dt

            of MoveLeft:
                transform.rotation -= vec3(1.0.Point, 0.0, 0.0) * dt * 0.001
            of MoveRight:
                transform.rotation += vec3(1.0.Point, 0.0, 0.0) * dt * 0.001
            of ZoomIn:
                transform.translation += vec3(1.0.Point, 0.0, 0.0) + front * dt * 0.001
            of ZoomOut:
                transform.translation -= vec3(1.0.Point, 0.0, 0.0) + front * dt * 0.001
            else:
                discard