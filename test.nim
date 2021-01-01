import tables, deques, bitops

const MAX_ENTITIES = 32
const MAX_COMPONENTS = 16

type
    Event = object
    Vec3[T] = array[3, T]

    EntityId = uint32
    Component = uint32
    
    Entity = ref object
        id: EntityId
        universe: Universe 

    Signature = BitsRange[Component]

    AbstractComponentList = ref object of RootObj

    ComponentList[T] = ref object of AbstractComponentList
        data: seq[T]

    Universe = ref object
        entityIdPool: Deque[EntityId]
        componentTypes: Table[string, Component]
        components: Table[Component, AbstractComponentList]
        entityComponents: Table[EntityId, Signature]

    Transform = object
        position: Vec3[float32]
        rotation: Vec3[float32]
        scale: Vec3[float32]

    Model = object
        file: string
        initialized: bool

    Sprite = object
        path: string

proc newUniverse(): Universe =
    result = Universe(
        componentTypes: initTable[string, Component](),
        components: initTable[Component, AbstractComponentList](),
        entityIdPool: initDeque[EntityId](MAX_ENTITIES),
        entityComponents: initTable[uint32, Signature]()
    )
    for i in 1..MAX_ENTITIES:
        result.entityIdPool.addLast(i.EntityId)


proc newEntity(universe: Universe): Entity =
    result = Entity(id: universe.entityIdPool.popFirst(), universe: universe)
    universe.entityComponents[result.id] = Signature(0)


proc add[T](universe: Universe, entity: Entity, component: T) =

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

proc remove(universe: Universe, entity: Entity, componentType: typedesc) =
    echo "Removing " & $componentType & " from entity " & $entity.id
    let componentTypeId = universe.componentTypes[$componentType]
    universe.entityComponents[entity.id].clearBit(componentTypeId)

proc destroy(universe: Universe, entity: Entity) =
    echo "Destroying entity " & $entity.id
    universe.entityComponents.del(entity.id)
    universe.entityIdPool.addLast(entity.id)


proc add[T](entity: Entity, component: T) =
    entity.universe.add(entity, component)

proc remove(entity: Entity, componentType: typedesc) =
    entity.universe.remove(entity, componentType)

# Usage
let universe = newUniverse()

let e1 = universe.newEntity()
let e2 = universe.newEntity()
let e3 = universe.newEntity()

e1.add(Transform())
e1.add(Model())

e2.add(Transform())

e3.add(Model())
e3.add(Sprite())

e3.remove(Sprite)

universe.destroy(e1)
universe.destroy(e2)
universe.destroy(e3)

