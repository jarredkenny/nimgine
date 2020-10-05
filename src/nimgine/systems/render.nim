import strformat
import glm, opengl

import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem()
renderSystem.matchComponent(Transform)
renderSystem.matchComponent(Mesh)

renderSystem.init = proc(world: World, system: System) =
    for entity in world.entitiesForSystem(renderSystem):
        var mesh: Mesh = entity.get(Mesh)
        mesh.init()

renderSystem.preRender = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        let mesh = entity.get(Mesh)
        let transform = entity.get(Transform)
        if mesh.initialized:
            scene.submit(mesh, transform)
