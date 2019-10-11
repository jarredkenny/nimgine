import ../ecs
import ../events
import ../components

var controller = newSystem()

controller.subscribe(@[
    MoveUp, MoveDown, MoveLeft, MoveRight
])

controller.matchComponent(Controllable)
controller.matchComponent(Position)

controller.update = proc(system: System, event: Event, dt: float) =
    for entity in entitiesForSystem(system):
        var position = entity.get(Position)
        case event.kind:
            of MoveUp: position.y += 1
            of MoveDown: position.y -= 1
            of MoveLeft: position.x -= 1
            of MoveRight: position.x += 1
            else: discard


ecs.add(controller)
