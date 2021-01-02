import tables, deques, bitops

import ../types

proc newUniverse*(): Universe =
    result = Universe(
        systems: newSeq[System](),
        componentTypes: initTable[string, Component](),
        components: initTable[Component, AbstractComponentList](),
        entityIdPool: initDeque[EntityId](MAX_ENTITIES),
        entityComponents: initTable[uint32, Signature]()
    )
    for i in 1..MAX_ENTITIES:
        result.entityIdPool.addLast(i.EntityId)


proc newEntity*(universe: Universe): Entity =
    result = Entity(id: universe.entityIdPool.popFirst(), universe: universe)
    universe.entityComponents[result.id] = Signature(0)

proc add*(universe: Universe, system: System) =
    universe.systems.add(system)

proc add*(universe: Universe, systems: seq[System]) =
    universe.systems = universe.systems & systems

proc add*[T](universe: Universe, entity: Entity, component: T) =

    if not universe.componentTypes.hasKey($typeof component):
        let id = universe.componentTypes.len.Component
        universe.componentTypes[$typeof component] = id
        universe.components[id] = ComponentList[typeof Component]()
        echo "Added " & $component.typeof & " as component type " & $id

    var componentTypeId = universe.componentTypes[$typeof component]

    cast[ComponentList[typeof component]](universe.components[componentTypeId]).data.add(component)
    
    echo "Creating entityComponent signature for entity: " & $entity.id
    universe.entityComponents[entity.id] = Signature(MAX_COMPONENTS)
    universe.entityComponents[entity.id].setBit(componentTypeId)

proc remove*(universe: Universe, entity: Entity, componentType: typedesc) =
    echo "Removing " & $componentType & " from entity " & $entity.id
    let componentTypeId = universe.componentTypes[$componentType]
    universe.entityComponents[entity.id].clearBit(componentTypeId)

proc destroy*(universe: Universe, entity: Entity) =
    echo "Destroying entity " & $entity.id
    universe.entityComponents.del(entity.id)
    universe.entityIdPool.addLast(entity.id)


proc add*[T](entity: Entity, component: T) =
    entity.universe.add(entity, component)

proc remove*(entity: Entity, componentType: typedesc) =
    entity.universe.remove(entity, componentType)

#[
    NEW STUFF
]#

proc init*(universe: Universe) =
  for system in universe.systems:
    if system.init != nil:
      system.init(universe, system)

iterator entitiesForSystem*(universe: Universe, system: System,
    limit: int = 0): Entity =
    discard
#   for i, entity in world.entities:
#     if limit > 0 and i > limit:
#       break
#     # UNIV: entity.component.hasKey would become universe.entityHas(Type[s])
#     # if all(toSeq(system.components), proc(
#         # s: string): bool = entity.components.hasKey(s)):
#     yield entity

proc entityForSystem*(universe: Universe, system: System): Entity =
  for entity in universe.entitiesForSystem(system, 1):
    return entity

proc update*(universe: Universe, dtUpdate: float, isFirstInFrame: bool) =
  for system in universe.systems:
    if system.update != nil and (isFirstInFrame or system.syncToFrame == isFirstInFrame):
      system.update(universe, system, dtUpdate)

proc handle*(universe: Universe, event: Event, dtUpdate: float, isFirstInFrame: bool) =
  for system in universe.systems:
    if system.handle != nil and event.kind in system.events and (isFirstInFrame or system.syncToFrame == isFirstInFrame):
      system.handle(universe, system, event, dtUpdate)

proc preRender*(universe: Universe, scene: Scene) =
  for system in universe.systems:
    if system.preRender != nil:
      system.preRender(universe, scene)

proc render*(universe: Universe, scene: Scene) =
  for system in universe.systems:
    if system.render != nil:
      system.render(universe, scene)