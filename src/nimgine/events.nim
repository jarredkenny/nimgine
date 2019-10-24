import deques

import types

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

proc on*(kind: EventType, callback: proc(): void) =
  callback()
