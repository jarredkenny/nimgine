import ../types
import ../ecs

import strformat
import glm

var controllerSystem* = newSystem(false)

controllerSystem.subscribe(@[
    MoveForward, MoveBackward, MoveLeft, MoveRight, PanUp, PanDown, PanLeft, PanRight
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Transform)


controllerSystem.handle = proc(app: Application, system: System, event: Event, dt: float) =

    for entity in app.world.entitiesForSystem(controllerSystem):
        var velocity = 0.1
        var transform = entity.get(Transform)
        var front = normalize(vec3(
            cos(radians(transform.rotation.x) * cos(radians(transform.rotation.y))),
            sin(radians(transform.rotation.y)),
            sin(radians(transform.rotation.x)) * cos(radians(transform.rotation.y))
        ))
        var right = normalize(cross(front, vec3(0.Point, 1.0, 0.0)))

        case event.kind:
        
            of MoveForward:
                transform.translation += front * dt * velocity
            
            of MoveBackward:
                transform.translation -= front * dt * velocity

            of MoveLeft:
                transform.translation -= right * dt * velocity

            of MoveRight:
                transform.translation += right * dt * velocity

            of PanUp:
                transform.rotation.y += dt * velocity
        
            of PanDown:
                transform.rotation.y -= dt * velocity

            of PanLeft:
                transform.rotation.x -= dt * velocity

            of PanRight:
                transform.rotation.x += dt * velocity
        
            else:
                discard

        if transform.rotation.y >= 89.0:
            transform.rotation.y = 89.0
        
        elif transform.rotation.y <= -89.0:
            transform.rotation.y = -89.0



        echo repr(transform.translation)
