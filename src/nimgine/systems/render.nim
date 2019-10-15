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
        0
    ])
    positions = newVertexBuffer(@[
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    ])

renderSystem.render = proc(scene: Scene, world: World) =

    for entity in world.entitiesForSystem(renderSystem):

        var mesh = newMesh(positions, elements, shader)

        scene.submit(mesh)
