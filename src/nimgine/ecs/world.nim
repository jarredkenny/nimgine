import sequtils, tables, sets

import glm

import ../types

var systemCount: int = 0

proc `$`*(w: World): string =
  result = "<World entities=" & $len(w.entities) & " systems=" & $len(
      w.systems) & ">"

proc newWorld*(): World =
  result = World(up: vec3(0.0.Point, 1.0, 0))

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
      system.update(app, system, app.clock.dtUpdate)

proc handle*(app: Application, event: Event) =
  for system in app.world.systems:
    if system.handle != nil and event.kind in system.events:
      system.handle(app, system, event, app.clock.dtUpdate)

proc preRender*(app: Application) =
  for system in app.world.systems:
    if system.preRender != nil:
      system.preRender(app.scene, app.world)

proc render*(app: Application) =
  for system in app.world.systems:
    if system.render != nil:
      system.render(app.scene, app.world)