import ../ecs
import ../components

var renderer = newSystem()

renderer.matchComponent(Position)
renderer.matchComponent(Dimensions)
renderer.matchComponent(RenderBlock)

renderer.render = proc(system: System) =
    echo($system.components)
    for entity in entitiesForSystem(system):
        echo(entity)

ecs.add(renderer)
