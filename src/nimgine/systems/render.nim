import strformat
import glm, opengl

import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem()
renderSystem.matchComponent(Position)
renderSystem.matchComponent(Dimensions)
renderSystem.matchComponent(RenderBlock)

var human, cube: Mesh

proc genVertex(px, py, pz, nx, ny, nz, tx, ty: float): Vertex =
    Vertex(
        position: vec3(px.float32, py, pz),
        normal: vec3(nx.float32, ny, nz),
        texCoord: vec2(tx.float32, ty)
    )

renderSystem.init = proc(world: World, system: System) =

    cube = newMesh(
        @[
            genVertex(-1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0),
            genVertex(1.0, -1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0),
            genVertex(1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0),
            genVertex(-1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0),
            genVertex(-1.0, -1.0, -1.0, 1.0, 0.0, 0.0, 0.0, 0.0),
            genVertex(1.0, -1.0, -1.0, 0.0, 1.0, 0.0, 0.0, 0.0),
            genVertex(1.0, 1.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0),
            genVertex(-1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 0.0, 0.0)
        ],
        @[
            0.GLuint, 1, 2,
            2, 3, 0,
            1, 5, 6,
            6, 2, 1,
            7, 6, 5,
            5, 4, 7,
            4, 0, 3,
            3, 7, 4,
            4, 5, 1,
            1, 0, 4,
            3, 2, 6,
            6, 7, 3
        ],
        newSeq[Texture](),
    )

    human = loadModel("models/HUMAN.blend")


renderSystem.render = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        # scene.submit(cube)
        scene.submit(human)
