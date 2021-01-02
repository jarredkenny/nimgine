import sets, strformat

import ../types
import ../ui
import ../ecs
import ../events

type
    ActiveKeyMap = HashSet[InputType]

var activeKeyMap = ActiveKeyMap()
var inputSystem* = newSystem(true)

var lastMousePosX: int = 0
var lastMousePosY: int = 0


inputSystem.subscribe(@[Input, MouseMove])

# Handle input events
# Update active map events so that events which are fired for every frame
# an update in active can fire on subsequent update events.
# For events which spawn for every input event received, spawn them
inputSystem.handle = proc(universe: Universe, system: System, event: Event, dt: float) =

    if event.kind == MouseMove:

        # Handle Mouse Motion
        if activeKeyMap.contains(MouseLeft) and event.kind == MouseMove:
            let diffX = event.x - lastMousePosX
            let diffY = event.y - lastMousePosY
            if diffX > 0:
                universe.app.bus.queueEvent(PanLeft)
            elif diffX < 0:
                universe.app.bus.queueEvent(PanRight)

            if diffY > 0:
                universe.app.bus.queueEvent(PanUp)
            elif diffY < 0:
                universe.app.bus.queueEvent(PanDown)

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
            
            # Remove key from active key map
            if activeKeyMap.contains(event.input):
                activeKeyMap.excl(event.input)

            # Fire events which only occur on a keyup
            case event.input:
                of KeyM: universe.app.bus.queueEvent(RenderModeMesh)
                of KeyF: universe.app.bus.queueEvent(RenderModeFull)
                else: discard
        

inputSystem.update = proc(universe: Universe, system: System, dt: float) =
    let app = universe.app

    # Input events based on active key map
    # These are events that fire for every frame a key is held down
    for input in activeKeyMap:
        case input:
            of KeyW: app.bus.queueEvent(MoveForward)
            of KeyS: app.bus.queueEvent(MoveBackward)
            of KeyA: app.bus.queueEvent(MoveLeft)
            of KeyD: app.bus.queueEvent(MoveRight)
            of KeyArrowUp: app.bus.queueEvent(PanUp)
            of KeyArrowDown: app.bus.queueEvent(PanDown)
            of KeyArrowLeft: app.bus.queueEvent(PanLeft)
            of KeyArrowRight: app.bus.queueEvent(PanRight)
            else: discard
