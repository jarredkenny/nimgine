import tables, typetraits

type
  Component = ref object
    id: int

  Entity = ref object
    id: int
    components: Table[string, Component]

  System = ref object
    id: int

  World = ref object
    id: int
    entities: seq[Entity]
    systems: seq[System]

# Id counters
var entityCount: int = 0
var componentCount: int = 0
var systemCount: int = 0
var worldCount: int = 0

# Component Functions
proc `$`(c: Component): string =
  result = "<Component id=" & $c.id & ">"

proc newComponent(): Component =
  inc(componentCount)
  result = Component(id: componentCount)

# Entity Functions
proc newEntity(): Entity =
  inc(entityCount)
  result = Entity(id: entityCount)

proc add[T](entity: Entity, component: T) =
  if not entity.components.hasKey(name(T)):
    entity.components.add(name(T), component)

proc get(entity: Entity, T: typedesc): T =
  if entity.components.hasKey(name(T)):
    result = entity.components[name(T)]

# System Functions
proc newSystem(): System =
  inc(systemCount)
  result = System(id: systemCount)

# World Functions
proc `$`(w: World): string =
  result = "<World entities=" & $len(w.entities) & " systems=" & $len(
      w.systems) & ">"

proc newWorld(): World =
  inc(worldCount)
  result = World(id: worldCount)

proc add(world: World, system: System) =
  world.systems.add(system)

proc add(world: World, entity: Entity) =
  world.entities.add(entity)

# Testing
var world: World = newWorld()
var system: System = newSystem()
var e1: Entity = newEntity()
var c1: Component = newComponent()

e1.add(c1)

world.add(e1)
world.add(system)

echo(c1)
echo(world)
