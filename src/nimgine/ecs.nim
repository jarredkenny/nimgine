import tables, typetraits, sugar, sets, sequtils, strformat

import types

# Id counters
var entityCount: int = 0
var componentCount: int = 0
var systemCount: int = 0

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

# ECS/world Functions
proc `$`*(w: World): string =
  result = "<World entities=" & $len(w.entities) & " systems=" & $len(
      w.systems) & ">"

proc newWorld*(): World =
  result = World()

proc add*(world: World, system: System) =
  world.systems.add(system)

proc add*(world: World, systems: seq[System]) =
  for system in systems:
    world.add(system)

proc add*(world: World, entity: Entity) =
  world.entities.add(entity)

proc add*(world: World, entities: seq[Entity]) =
  for entity in entities:
    world.add(entity)

proc newSystem*(): System =
  inc(systemCount)
  result = System(id: systemCount)

proc init*(app: Application) =
  for system in app.world.systems:
    if system.init != nil:
      system.init(app.world, system)

iterator entitiesForSystem*(world: World, system: System,
    limit: int = 0): Entity =
  for i, entity in world.entities:
    if limit > 0 and i > limit:
      break
    if all(toSeq(system.components), proc(
        s: string): bool = entity.components.hasKey(s)):
      yield entity

proc entityForSystem*(world: World, system: System): Entity =
  for entity in world.entitiesForSystem(system, 1):
    return entity

proc update*(app: Application) =
  for system in app.world.systems:
    if system.update != nil:
      system.update(app, system, app.clock.dt)

proc handle*(app: Application, event: Event) =
  for system in app.world.systems:
    if system.handle != nil and event.kind in system.events:
      system.handle(app, system, event, app.clock.dt)

proc preRender*(app: Application) =
  for system in app.world.systems:
    if system.preRender != nil:
      system.preRender(app.scene, app.world)

proc render*(app: Application) =
  for system in app.world.systems:
    if system.render != nil:
      system.render(app.scene, app.world)


var WorldLayer* = ApplicationLayer()

WorldLayer.init = init
WorldLayer.handle = handle
WorldLayer.update = update
WorldLayer.preRender = preRender
WorldLayer.render = render
