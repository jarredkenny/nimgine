import deques

import input

type

  EventType* = enum
    Quit
    Resize
    Input
    MouseMove

  Event* = ref object
    case kind*: EventType
    of Input:
      input*: InputType
      state*: bool
    of MouseMove:
      x*, y*: int
    else:
      discard

  EventQueue = Deque[Event]


proc `$`*(e: Event): string =
  result = "<Event kind=" & $e.kind & ">"

proc newEventQueue*(): EventQueue =
  result = initDeque[Event]()

var queue = newEventQueue()

proc queueEvent*(evt: Event) =
  queue.addLast(evt)

iterator pollEvent*(): Event =
  while queue.len > 0:
    yield queue.popFirst()

proc newEvent*(kind: EventType): Event =
  result = Event(kind: kind)

proc newInputEvent*(input: InputType, state: bool): Event =
  result = Event(kind: Input, input: input, state: state)

proc newMouseMoveEvent*(x, y: int): Event =
  result = Event(kind: MouseMove, x: x, y: y)
