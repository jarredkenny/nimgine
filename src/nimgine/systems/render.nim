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

renderSystem.init = proc(world: World, system: System) =
    shader = newShader(
        """
        #version 440 core
        uniform mat4 MVP;
        in vec2 position;
        void main() {
            gl_Position = vec4(position, 1.0, 1.0) * MVP;
        }
        """,
        """
        #version 440 core
        out vec4 color;
        void main() {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        }
        """
    )
    elements = newIndexBuffer(@[
        0, 1, 2,
        2, 3, 0
    ])

renderSystem.render = proc(world: World, system: System) =

    for entity in world.entitiesForSystem(system):

        var p = entity.get(Position)
        var d = entity.get(Dimensions)

        var positions = newVertexBuffer(@[
            p.x, p.y,
            p.x, (p.y + d.height),
            (p.x + d.width), (p.y + d.height),
            (p.x + d.width), p.y
        ])

        var mesh = newMesh(positions, elements, shader)

        renderer.submit(mesh)
