import ../types
import ../ecs
import ../renderer

var renderSystem* = newSystem()
renderSystem.matchComponent(Position)
renderSystem.matchComponent(Dimensions)
renderSystem.matchComponent(RenderBlock)

var floor, cube: Mesh

renderSystem.init = proc(world: World, system: System) =


    cube = newMesh(
        @[
            newVertexBuffer(
                "position",
                @[
                    -1.0, -1.0, 1.0,
                    1.0, -1.0, 1.0,
                    1.0, 1.0, 1.0,
                    -1.0, 1.0, 1.0,
                    -1.0, -1.0, -1.0,
                    1.0, -1.0, -1.0,
                    1.0, 1.0, -1.0,
                    -1.0, 1.0, -1.0
        ],
        3, 3, 0
    ),
            newVertexBuffer(
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
        ],
        newIndexBuffer(@[
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
        ]),
        newShader(
            """
            #version 440 core

            in vec3 position;
            in vec3 color;

            out vec3 fragmentColor;

            uniform mat4 MVP;

            void main() {
                fragmentColor = color;
                gl_Position = MVP * vec4(position, 1.0);
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
    )


renderSystem.render = proc(scene: Scene, world: World) =
    for entity in world.entitiesForSystem(renderSystem):
        scene.submit(cube)
        scene.submit(cube)
