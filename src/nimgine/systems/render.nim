import strformat
import glm, opengl

import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem(true)
renderSystem.matchComponent(Transform)
renderSystem.matchComponent(Model)

renderSystem.subscribe(@[RenderModeMesh, RenderModeFull])

renderSystem.preRender = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        var model: Model = entity.get(Model)
        if not model.initialized:
            model.init()

renderSystem.render = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        var model: Model = entity.get(Model)
        let transform = entity.get(Transform)
        
        if model.initialized:
            scene.submit(model, transform)
