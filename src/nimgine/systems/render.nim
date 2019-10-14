import ../ecs
import ../components
import ../renderer

var renderSystem = newSystem()
renderSystem.matchComponent(Position)
renderSystem.matchComponent(Dimensions)
renderSystem.matchComponent(RenderBlock)

var shader: Shader

renderSystem.init = proc(system: System) =
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


renderSystem.render = proc(system: System) =

    for entity in entitiesForSystem(system):

        var p = entity.get(Position)
        var d = entity.get(Dimensions)

        var positions = newVertexBuffer(@[
            p.x, p.y,
            p.x, (p.y + d.height),
            (p.x + d.width), (p.y + d.height),
            (p.x + d.width), p.y
        ])

        var elements = newIndexBuffer(@[
            0, 1, 2,
            2, 3, 0
        ])

        var mesh: Mesh = newMesh(positions, elements, shader)

        renderer.submit(mesh)

ecs.add(renderSystem)
