import sets

import ../types
import ../ui
import ../ecs
import ../events

type
    ActiveKeyMap = HashSet[InputType]

var activeKeyMap = ActiveKeyMap()
var inputSystem* = newSystem()

var lastMousePosX: int = 0
var lastMousePosY: int = 0

inputSystem.subscribe(@[Input, MouseMove])

# Handle input events
# Update active map events so that events which are fired for every frame
# an update in active can fire on subsequent update events.
# For events which spawn for every input event received, spawn them
inputSystem.handle = proc(world: World, system: System, event: Event) =

    if event.kind == MouseMove:

        # Handle Click+Drag (MouseDown active, while MouseMove occurs
        if activeKeyMap.contains(MouseLeft) and event.kind == MouseMove:
            let diffX = event.x - lastMousePosX
            let diffY = event.y - lastMousePosY
            if diffX > 0:
                queueEvent(newEvent(MoveLeft))
            elif diffX < 0:
                queueEvent(newEvent(MoveRight))

            if diffY > 0:
                queueEvent(newEvent(MoveUp))
            elif diffY < 0:
                queueEvent(newEvent(MoveDown))

        # Update stored mouve position
        if event.kind == MouseMove:
            lastMousePosX = event.x
            lastMousePosY = event.y


    if event.kind == Input:

        # When an input event occurs, update that inputs state in our key map
        if event.state:
            if not activeKeyMap.contains(event.input):
                activeKeyMap.incl(event.input)
        else:
            if activeKeyMap.contains(event.input):
                activeKeyMap.excl(event.input)

        # Input Events based on events that occur within a frame
        # and spawn new events only when received

        # Handle Mouse Wheel Zooming
        case event.input:
            of InputType.MouseScrollUp: queueEvent(EventType.ZoomIn)
            of InputType.MouseScrollDown: queueEvent(EventType.ZoomOut)
            else: discard

inputSystem.update = proc(world: World, system: System, dt: float) =

    # Input events based on active key map
    # These are events that fire for every frame a key is held down
    for input in activeKeyMap:
        case input:
            of KeyW: queueEvent(MoveUp)
            of KeyS: queueEvent(MoveDown)
            of KeyA: queueEvent(MoveLeft)
            of KeyD: queueEvent(MoveRight)
            of KeyEscape: queueEvent(EventType.Quit)
            else: discard


