import sets

import ../types
import ../ui
import ../ecs
import ../events

type
    ActiveKeyMap = HashSet[InputType]

var activeKeyMap = ActiveKeyMap()
var inputSystem* = newSystem()

inputSystem.subscribe(@[Input, Update])

proc handleInputStateOn(input: InputType) =
    case input:
        of MouseLeft:
            ui.setMouseDown(1, true)
        of MouseRight:
            ui.setMouseDown(2, true)
        else: discard

proc handleInputStateOff(input: InputType) =
    case input:
        of MouseLeft:
            ui.setMouseDown(1, false)
        of MouseRight:
            ui.setMouseDown(2, false)
        else: discard

inputSystem.update = proc(world: World, system: System, event: Event, dt: float) =

    # When an input event occurs, update that inputs state in our key map
    if event.kind == Input:
        if event.state:
            if not activeKeyMap.contains(event.input):
                handleInputStateOn(event.input)
                activeKeyMap.incl(event.input)
        else:
            if activeKeyMap.contains(event.input):
                handleInputStateOff(event.input)
                activeKeyMap.excl(event.input)

    # Handle event that fire every frame if an input is active
    if event.kind == Update:
        for input in activeKeyMap:
            case input:
                of Up: queueEvent(MoveUp)
                of Down: queueEvent(MoveDown)
                of Left: queueEvent(MoveLeft)
                of Right: queueEvent(MoveRight)
                # of InputType.Quit: queueEvent(EventType.Quit)
                # of InputType.ZoomIn: queueEvent(EventType.ZoomIn)
                # of InputType.ZoomOut: queueEvent(EventType.ZoomOut)
                else: discard
