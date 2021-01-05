import tables, deques, bitops, sequtils, sets

import ../types

#[
  Component List
]#

proc add*[T](list: ComponentList[T], entity: Entity, component: T) =
  let newIndex = list.data.len
  list.entityIndexMap[entity.id] = newIndex
  list.indexEntityMap[newIndex] = entity.id
  list.data.add(component)


proc remove*[T](list: ComponentList[T], entity: Entity) =
  let indexOfEntity = list.entityIndexMap[entity.id]
  let indexOfLastElement = list.data.len - 1

  list.data[indexOfEntity] = list.data[indexOfLastElement]

  let entityIdOfLastElement = list.indexEntityMap[indexOfLastElement]
  list.entityIndexMap[entityIdOfLastElement] = indexOfEntity
  list.indexEntityMap[indexOfEntity] = entityIdOfLastElement

  list.data.del(indexOfLastElement)

proc get*[T](list: ComponentList[T], entity: Entity, componentType: typedesc): T =
  result = list.data.get(list.entityIndexMap[entity.id])

#[
  Universe
]#

proc newUniverse*(): Universe =
    result = Universe(
        entities: initTable[EntityId, Entity](),
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
    universe.entities[result.id] = result
    echo "Creating entityComponent signature for entity: " & $result.id
    universe.entityComponents[result.id] = Signature(0)

proc add*(universe: Universe, system: System) =
    echo "Adding system to universe"
    universe.systems.add(system)
    
proc add*(universe: Universe, systems: seq[System]) =
  for system in systems:
    universe.systems.add(system)

proc initComponentList(universe: Universe, componentType: typedesc) =
  let id = universe.componentTypes.len.Component
  universe.componentTypes[$componentType] = id
  universe.components[id] = ComponentList[type[componentType]]()
  echo "Added " & $componentType & " as component type " & $id

proc componentListFor[T](universe: Universe, component: T): ComponentList[T] =
  if not universe.componentTypes.hasKey($typeof(component)):
    universe.initComponentList(typeof(component))
  var componentTypeId = universe.componentTypes[$typeof component] 
  result = cast[ComponentList[T]](universe.components[componentTypeId])


proc add*[T](universe: Universe, entity: Entity, component: T) =

    universe.initComponentList(typeof component)
    universe.componentListFor(component).add(entity, component)

    var componentTypeId = universe.componentTypes[$typeof component] 
    universe.entityComponents[entity.id].setBit(componentTypeId)

proc remove*(universe: Universe, entity: Entity, componentType: typedesc) =
    echo "Removing " & $componentType & " from entity " & $entity.id
    let componentTypeId = universe.componentTypes[$componentType]
    universe.entityComponents[entity.id].clearBit(componentTypeId)

proc destroy*(universe: Universe, entity: Entity) =
    echo "Destroying entity " & $entity.id

    for key in universe.components.keys:
      universe.componentListFor(key).remove(entity)
      
    universe.entities.del(entity.id)
    universe.entityComponents.del(entity.id)
    universe.entityIdPool.addLast(entity.id)

proc get*(universe: Universe, entity: Entity, T: typedesc): T =
  result = universe.componentListFor(T.typeof).get(entity, T.typeof)

iterator entitiesWith*(universe: Universe, components: HashSet[string]): Entity =
  let compTypes = map(components.toSeq, proc(s: string): Component = universe.componentTypes.getOrDefault(s))

  for entityId in universe.entityComponents.keys:
    let entityMatches = all(compTypes, proc(c: Component): bool = universe.entityComponents[entityId].testBit(c))
    if entityMatches:
      yield universe.entities[entityId]

proc init*(universe: Universe) =
  for system in universe.systems:
    if system.init != nil:
      system.init(universe, system)

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


#[
  Entity Level Helpers
]#
proc destroy*(entity: Entity) =
  entity.universe.destroy(entity)

proc add*[T](entity: Entity, component: T) =
  entity.universe.add(entity, component)

proc remove*(entity: Entity, componentType: typedesc) =
  entity.universe.remove(entity, componentType)

# proc get*(entity: Entity, T: typedesc): T =
#   result = cast[T](entity.universe.get(entity, T))