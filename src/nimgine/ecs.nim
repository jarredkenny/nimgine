import tables, typetraits, sugar

import events

type
  Component* = ref object
    id*: int

  Entity* = ref object
    id*: int
    components*: Table[string, Component]

  System* = ref object
    id*: int
    events: set[Event]
    init*: proc(system: System)
    update*: proc(system: System, event: Event, dt: float)
    render*: proc(system: System)

  World* = ref object
    id*: int
    entities*: seq[Entity]
    systems*: seq[System]

# Id counters
var entityCount: int = 0
var componentCount: int = 0
var systemCount: int = 0
var worldCount: int = 0

# Component Functions
proc `$`(c: Component): string =
  result = "<Component id=" & $c.id & ">"

proc newComponent*(): Component =
  inc(componentCount)
  result = Component(id: componentCount)

# Entity Functions
proc newEntity*(): Entity =
  inc(entityCount)
  result = Entity(id: entityCount)

proc add*[T](entity: Entity, component: T) =
  if not entity.components.hasKey(name(T)):
    entity.components.add(name(T), component)

proc get*(entity: Entity, T: typedesc): T =
  if entity.components.hasKey(name(T)):
    result = entity.components[name(T)]

# System Functions
proc `$`(system: System): string =
  result = "<System id=" & $system.id & ">"

proc newSystem*(): System =
  inc(systemCount)
  result = System(id: systemCount)

proc subscribe*(system: System, event: Event) =
  if event notin system.events:
    system.events.incl(event)

proc subscribe*(system: System, events: seq[Event]) =
  for event in events:
    system.subscribe(event)

proc unsubscribe*(system: System, event: Event) =
  system.events.excl(event)

proc unsubscribe*(system: System, events: seq[Event]) =
  for event in events:
    system.unsubscribe(event)

# World Functions
proc `$`(w: World): string =
  result = "<World entities=" & $len(w.entities) & " systems=" & $len(
      w.systems) & ">"

proc newWorld*(): World =
  inc(worldCount)
  result = World(id: worldCount)

proc add*(world: World, system: System) =
  world.systems.add(system)

proc add*(world: World, entity: Entity) =
  world.entities.add(entity)

proc init*(world: World) =
  for system in world.systems:
    if system.init != nil:
      system.init(system)

proc update*(world: World, event: Event, dt: float) =
  for system in world.systems:
    if system.update != nil and event in system.events:
      system.update(system, event, dt)

proc render*(world: World) =
  for system in world.systems:
    if system.render != nil:
      system.render(system)
