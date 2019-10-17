import deques

import input

type

  EventType* = enum

    # Game Loop Events
    Update
    Render

    # Input Type Events
    Input
    MouseMove

    # Platform State Events
    Quit
    Resize

    # Control Intents
    MoveUp
    MoveDown
    MoveLeft
    MoveRight
    ZoomIn
    ZoomOut

  Event* = ref object
    case kind*: EventType
    of Input:
      input*: InputType
      state*: bool
    of MouseMove:
      x*, y*: int
    of Resize:
      width*, height*: int
    else:
      discard

  EventQueue = Deque[Event]


proc `$`*(e: Event): string =
  result = "<Event kind=" & $e.kind & ">"

proc newEventQueue*(): EventQueue =
  result = initDeque[Event]()

var queue = newEventQueue()

iterator pollEvent*(): Event =
  while queue.len > 0:
    yield queue.popFirst()

proc newEvent*(kind: EventType): Event =
  result = Event(kind: kind)

proc newInputEvent*(input: InputType, state: bool): Event =
  result = Event(kind: Input, input: input, state: state)

proc newMouseMoveEvent*(x, y: int): Event =
  result = Event(kind: MouseMove, x: x, y: y)

proc newResizeEvent*(width, height: int): Event =
  result = Event(kind: Resize, width: width, height: height)

proc queueEvent*(evt: Event) =
  queue.addLast(evt)

proc queueEvent*(kind: EventType) =
  queueEvent(newEvent(kind))
