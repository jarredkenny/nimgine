import tables, typetraits, sugar, sets, sequtils

import events

type
  Component* = ref object of RootObj
    id*: int

  Entity* = ref object
    id*: int
    components*: Table[string, Component]

  System* = ref object
    id*: int
    events: set[EventType]
    components*: HashSet[string]
    init*: proc(system: System)
    update*: proc(system: System, event: Event, dt: float)
    preRender*: proc(system: System)
    render*: proc(system: System)

  World* = ref object
    entities*: seq[Entity]
    systems*: seq[System]

# Id counters
var entityCount: int = 0
var componentCount: int = 0
var systemCount: int = 0

# Game World
var world = World()

# Component Functions
proc `$`*(c: Component): string =
  result = "<Component id=" & $c.id & ">"

proc newComponent*(): Component =
  inc(componentCount)
  result = Component(id: componentCount)

# Entity Functions
proc `$`*(entity: Entity): string =
  result = "<Entity id=" & $entity.id & ">"

proc newEntity*(): Entity =
  inc(entityCount)
  result = Entity(id: entityCount)

proc add*[T](entity: Entity, component: T) =
  if not entity.components.hasKey(name(T)):
    entity.components.add(name(T), component)

proc get*(entity: Entity, T: typedesc): T =
  if entity.components.hasKey(name(T)):
    result = cast[T](entity.components[name(T)])

# System Functions
proc `$`*(system: System): string =
  result = "<System tem): Entity = for entity in world.entities:id=" &
      $system.id & ">"

proc newSystem*(): System =
  inc(systemCount)
  result = System(id: systemCount)

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

# ECS/world Functions
proc `$`*(w: World): string =
  result = "<World entities=" & $len(w.entities) & " systems=" & $len(
      w.systems) & ">"

proc add*(system: System) =
  world.systems.add(system)

proc add*(entity: Entity) =
  world.entities.add(entity)

proc init*() =
  for system in world.systems:
    if system.init != nil:
      system.init(system)

iterator entitiesForSystem*(system: System): Entity =
  for entity in world.entities:
    if all(toSeq(system.components), proc(
        s: string): bool = entity.components.hasKey(s)):
      yield entity

proc update*(event: Event, dt: float) =
  for system in world.systems:
    if system.update != nil and event.kind in system.events:
      system.update(system, event, dt)

proc preRender*() =
  for system in world.systems:
    if system.preRender != nil:
      system.preRender(system)

proc render*() =
  for system in world.systems:
    if system.render != nil:
      system.render(system)
