import tables, sets, typetraits

import ../types

proc `$`*(system: System): string =
  result = "<System id=" &
      $system.id & ">"

proc subscribe*(system: System, event: EventType) =
  if event notin system.events:
    system.events.incl(event)

proc subscribe*(system: System, events: seq[EventType]) =
  for event in events:
    system.subscribe(event)

proc unsubscribe*(system: System, event: EventType) =
  system.events.excl(event)

proc unsubscribe*(system: System, events: seq[EventType]) =
  for event in events:
    system.unsubscribe(event)

proc matchComponent*(system: System, component: string) =
  system.components.incl(component)

proc matchComponent*(system: System, component: typedesc) =
  system.matchComponent(name(component))

proc matchComponents*(system: System, components: seq[string]) =
  for component in components:
    system.matchComponent(component)

proc matchComponents*(system: System, components: seq[typedesc]) =
  for component in components:
    system.matchComponent(name(component))
