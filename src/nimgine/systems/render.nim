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

renderSystem.update = proc(app: Application, system: System, dt: float) =
    for entity in app.world.entitiesForSystem(renderSystem):
        let transform: Transform = entity.get(Transform)
        let mesh: Mesh = entity.get(Mesh)
        if mesh.initialized:
            mesh.model = translate(mat4(1.Glfloat), vec3(
                    transform.translation.x.GLfloat, transform.translation.y,
                    transform.translation.z))

renderSystem.preRender = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        let mesh = entity.get(Mesh)
        if mesh.initialized:
            scene.submit(mesh)
