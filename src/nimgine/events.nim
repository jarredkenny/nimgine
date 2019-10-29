import deques

import types

proc `$`*(e: Event): string =
  result = "<Event kind=" & $e.kind & ">"

proc newEventQueue*(): EventQueue =
  result = EventQueue(queue: initDeque[Event]())

var queue = newEventQueue()

proc emit*(q: var EventQueue, e: Event) =
  q.queue.addLast(e)

iterator pollEvent*(): Event =
  while queue.queue.len > 0:
    yield queue.queue.popFirst()

proc newEvent*(kind: EventType): Event =
  result = Event(kind: kind)

proc newInputEvent*(input: InputType, state: bool): Event =
  result = Event(kind: Input, input: input, state: state)

proc newInputEvent*(input: InputType, state: bool, unicode: uint32): Event =
  result = Event(kind: Input, input: input, state: state, unicode: unicode)

proc newInputEvent*(input: InputType): Event =
  result = Event(kind: Input, input: input)

proc newMouseMoveEvent*(x, y: int): Event =
  result = Event(kind: MouseMove, x: x, y: y)

proc newResizeEvent*(width, height: int): Event =
  result = Event(kind: Resize, width: width, height: height)

proc newCharEvent*(charecter: char): Event =
  result = Event(kind: EventType.Charecter, charecter: charecter)

proc queueEvent*(evt: Event) =
  queue.emit(evt)

proc queueEvent*(kind: EventType) =
  queueEvent(newEvent(kind))

proc markHandled*(event: Event) =
  event.handled = true
