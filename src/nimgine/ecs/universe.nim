import tables, deques, bitops, sequtils, sets

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
    echo "Creating entityComponent signature for entity: " & $result.id
    universe.entityComponents[result.id] = Signature(0)

proc add*(universe: Universe, system: System) =
    echo "Adding system to universe"
    universe.systems.add(system)
    

proc add*(universe: Universe, systems: seq[System]) =
  for system in systems:
    universe.systems.add(system)

proc add*[T](universe: Universe, entity: Entity, component: T) =

    if not universe.componentTypes.hasKey($typeof component):
        let id = universe.componentTypes.len.Component
        universe.componentTypes[$typeof component] = id
        universe.components[id] = ComponentList[typeof Component]()
        echo "Added " & $component.typeof & " as component type " & $id

    var componentTypeId = universe.componentTypes[$typeof component]

    cast[ComponentList[typeof component]](universe.components[componentTypeId]).data.add(component)
    
    
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


proc init*(universe: Universe) =
  for system in universe.systems:
    if system.init != nil:
      system.init(universe, system)

iterator entitiesWith*(universe: Universe, components: HashSet[string]): Entity =
  let compTypes = map(components.toSeq, proc(s: string): Component = universe.componentTypes.getOrDefault(s))

  for entityId in universe.entityComponents.keys:
      if all(compTypes, proc(c: Component): bool = universe.entityComponents[entityId].testBit(c)):
        yield Entity(id: entityId, universe: universe)


iterator entitiesForSystem*(universe: Universe, system: System, limit: int = 0): Entity =
    discard
#   for i, entity in world.entities:
#     if limit > 0 and i > limit:
#       break
#     # UNIV: entity.component.hasKey would become universe.entityHas(Type[s])
#     # if all(toSeq(system.components), proc(
#         # s: string): bool = entity.components.hasKey(s)):
#     yield entity



# iterator matchedEntities*(system: System): Entity =

  # var typeIds = map(toSeq(system.components), proc(s: string) = s)

  # # let componentTypeIds = map(toSeq(system.components), proc(t: string) = universe.componentTypes.get(t))

  # # echo "componentTypeIds: " & $componentTypeIds

  # # for entityId in universe.entityComponents.keys:
  # #   echo "Checking compoenents on entity: " & $entityId

  # #   yield Entity()


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