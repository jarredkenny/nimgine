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
var elements: IndexBuffer
var positions: VertexBuffer

renderSystem.init = proc(world: World, system: System) =
    shader = newShader(
        """
        #version 440 core
        uniform mat4 MVP;
        in vec3 position;
        in vec3 color;
        out vec3 newColor;
        void main() {
            newColor = color;
            gl_Position = vec4(position, 1.0) * MVP;
        }
        """,
        """
        #version 440 core
        in vec3 newColor;
        out vec4 color;
        void main() {
            color = vec4(newColor, 1.0);
        }
        """
    )
    elements = newIndexBuffer(@[
        0, 1, 2, 2, 3, 0,
        4, 5, 6, 6, 7, 4,
        8, 9, 10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20
    ])
    positions = newVertexBuffer(@[
        50.Glfloat,
        50,
        150,
        200,
        100,
        100,
        100,
        150,
        50,
        150,
        100,
        200,
        100,
        200,
        150,
        150,
        150,
        100,
        100,
        200,
        200,
        50,
        150,
        150,
        200,
        200,
        200,
        100,
        50,
        50,
        50,
        200,
        100,
        100,
        100,
        150,
        50,
        50,
        100,
        200,
        100,
        200,
        150,
        150,
        50,
        100,
        100,
        200,
        200,
        50,
        150,
        50,
        200,
        200,
        200,
        100,
        150,
        50,
        50,
        200,
        100,
        100,
        100,
        150,
        150,
        50,
        100,
        200,
        100,
        200,
        150,
        150,
        150,
        100,
        100,
        200,
        200,
        150,
        50,
        150,
        200,
        200,
        200,
        100,
        50,
        150,
        50,
        200,
        100,
        100,
        100,
        50,
        50,
        50,
        100,
        200,
        100,
        200,
        50,
        50,
    ])

renderSystem.render = proc(scene: Scene, world: World) =

    for entity in world.entitiesForSystem(renderSystem):

        var mesh = newMesh(positions, elements, shader)

        scene.submit(mesh)
