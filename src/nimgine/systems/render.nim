import strformat
import glm, opengl

import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem(true)
renderSystem.matchComponent(Transform)
renderSystem.matchComponent(Model)

renderSystem.subscribe(@[RenderModeMesh, RenderModeFull])

renderSystem.preRender = proc(universe: Universe, scene: Scene) =
    for entity in universe.entitiesForSystem(renderSystem):
        discard
        # UNIV: get model component from entity
        # var model: Model = entity.get(Model)
        # if not model.initialized:
        #     model.init()

renderSystem.render = proc(universe: Universe, scene: Scene) =
    for entity in universe.entitiesForSystem(renderSystem):
        discard
        # UNIV: get model component form entity
        # var model: Model = entity.get(Model)
        # let transform = entity.get(Transform)
        
        # if model.initialized:
        #     scene.submit(model, transform)
