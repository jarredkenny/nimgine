import deques

type
  Event* = enum
    Quit
    Resize

  EventQueue = Deque[Event]

proc newEventQueue*(): EventQueue =
  result = initDeque[Event]()

var eventQueue = newEventQueue()

proc queueEvent*(evt: Event) =
  echo("Queue event: " & $evt)
  eventQueue.addLast(evt)

iterator pollEvent*(): Event =
  while eventQueue.len > 0:
    yield eventQueue.popFirst()
