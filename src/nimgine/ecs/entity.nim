import typetraits, tables

import ../types

var entityCount: int = 0

proc newEntity*(): Entity =
  inc(entityCount)
  result = Entity(id: entityCount)

proc `$`*(entity: Entity): string =
  result = "<Entity id=" & $entity.id & ">"

proc add*[T](entity: Entity, component: T) =
  if not entity.components.hasKey(name(T)):
    entity.components.add(name(T), component)

proc get*(entity: Entity, T: typedesc): T =
  if entity.components.hasKey(name(T)):
    result = cast[T](entity.components[name(T)])
