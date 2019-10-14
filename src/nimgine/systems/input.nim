import sets

import ../input
import ../ecs
import ../events

type
    ActiveKeyMap = HashSet[InputType]

var activeKeyMap = ActiveKeyMap()
var inputSystem* = newSystem()

inputSystem.subscribe(@[Input, Update])

inputSystem.update = proc(world: World, system: System, event: Event, dt: float) =
    if event.kind == Input:
        if event.state:
            activeKeyMap.incl(event.input)
        else:
            activeKeyMap.excl(event.input)

    if event.kind == Update:
        for input in activeKeyMap:
            case input:
                of Up: queueEvent(MoveUp)
                of Down: queueEvent(MoveDown)
                of Left: queueEvent(MoveLeft)
                of Right: queueEvent(MoveRight)
                of InputType.ZoomIn: queueEvent(EventType.ZoomIn)
                of InputType.ZoomOut: queueEvent(EventType.ZoomOut)
                else: discard
