import ../types
import ../ecs

import strformat, math
import glm

var controllerSystem* = newSystem(false)

controllerSystem.subscribe(@[
    MoveForward, MoveBackward, MoveLeft, MoveRight, PanUp, PanDown, PanLeft, PanRight
])

controllerSystem.matchComponent(Controllable)
controllerSystem.matchComponent(Transform)


controllerSystem.handle = proc(universe: Universe, system: System, event: Event, dt: float) =

    discard
    # for entity in universe.entitiesForSystem(controllerSystem):
    #     var velocity = 100.0
    #     # UNIV: get component from model
        # var transform = entity.get(Transform)
        # var front = normalize(vec3(
        #     cos(radians(transform.rotation.x) * cos(radians(transform.rotation.y))),
        #     sin(radians(transform.rotation.y)),
        #     sin(radians(transform.rotation.x)) * cos(radians(transform.rotation.y))
        # ))
        # var right = normalize(cross(front, vec3(0.Point, 1.0, 0.0)))

        # case event.kind:
        
        #     of MoveForward:
        #         transform.translation += front * dt * velocity
            
        #     of MoveBackward:
        #         transform.translation -= front * dt * velocity

        #     of MoveLeft:
        #         transform.translation -= right * dt * velocity

        #     of MoveRight:
        #         transform.translation += right * dt * velocity

        #     of PanUp:
        #         transform.rotation.y += dt * velocity
        
        #     of PanDown:
        #         transform.rotation.y -= dt * velocity

        #     of PanLeft:
        #         transform.rotation.x -= dt * velocity

        #     of PanRight:
        #         transform.rotation.x += dt * velocity
        
        #     else:
        #         discard

        # if transform.rotation.y >= 89.0:
        #     transform.rotation.y = 89.0
        
        # elif transform.rotation.y <= -89.0:
        #     transform.rotation.y = -89.0

        # if transform.rotation.x >= 360.0:
        #     transform.rotation.x = 0.0
        # elif transform.rotation.x <= 0.0:
        #     transform.rotation.x = 360.0
