import strformat
import glm, opengl

import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem()
renderSystem.matchComponent(Position)
renderSystem.matchComponent(Dimensions)
renderSystem.matchComponent(RenderBlock)

var human: Mesh

renderSystem.init = proc(world: World, system: System) =
    human = loadModel("models/airboat.obj")

renderSystem.render = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        scene.submit(human)
