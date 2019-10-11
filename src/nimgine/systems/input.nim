import sets

import ../input
import ../ecs
import ../events

type
    ActiveKeyMap = HashSet[InputType]

var activeKeyMap = ActiveKeyMap()
var inputSystem = newSystem()

inputSystem.subscribe(@[Input, Update])

inputSystem.update = proc(system: System, event: Event, dt: float) =
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
                else: discard


ecs.add(inputSystem)
