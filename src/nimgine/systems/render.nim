import ../ecs
import ../renderer
from ../events import Update
from ../components import Position, Dimensions, RenderBlock

var renderSystem* = newSystem()
renderSystem.subscribe(Update)
renderSystem.matchComponent(Position)
renderSystem.matchComponent(Dimensions)
renderSystem.matchComponent(RenderBlock)

var shader: Shader
var colors: VertexBuffer
var elements: IndexBuffer
var positions: VertexBuffer
var mesh: Mesh

renderSystem.init = proc(world: World, system: System) =

    shader = newShader(
        """
        #version 440 core

        layout(location = 1) in vec3 position;
        layout(location = 2) in vec3 color;

        out vec3 fragmentColor;

        uniform mat4 MVP;

        void main() {
            gl_Position = vec4(position, 1.0) * MVP;
        }
        """,
        """
        #version 440 core
        in vec3 fragmentColor;
        out vec4 color;
        void main() {
            color = vec4(fragmentColor, 1.0);
        }
        """
    )

    positions = newVertexBuffer(
        "position",
        @[
            -20.0, -20.0, 20.0,
            20.0, -20.0, 20.0,
            20.0, 20.0, 20.0,
            -20.0, 20.0, 20.0
        ],
        3, 3, 0
    )

    colors = newVertexBuffer(
        "color",
        @[
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0,
            1.0, 1.0, 1.0,
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 0.0, 1.0,
            1.0, 1.0, 1.0
        ],
        3, 3, 0
    )

    elements = newIndexBuffer(@[
        0, 1, 2,
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
    ])

    mesh = newMesh(@[positions, colors], elements, shader)

    mesh.init()

renderSystem.render = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        scene.submit(mesh)