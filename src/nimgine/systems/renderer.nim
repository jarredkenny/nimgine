import opengl

import ../ecs
import ../components

type
    Vertex = ref object
        x, y: GLfloat

proc compileShader(shaderType: uint, source: string): uint =
    var id: uint = glCreateShader(shaderType.GLenum)
    var src: cstringarray = allocCStringArray([source])
    glShaderSource(id.GLuint, 1.GLsizei, src, nil)
    glCompileShader(id.GLuint)

    var compiled: GLint;
    glGetShaderiv(id.GLuint, GL_COMPILE_STATUS, addr(compiled))

    if compiled == 0:
        var length: GLSizei;
        glGetShaderiv(id.GLuint, GL_INFO_LOG_LENGTH, addr(length))
        var message: string = newString(length)
        glGetShaderInfoLog(id.GLuint, length, addr(length), message)
        echo("Shader compilation error: " & $message)


    result = id

proc createShader(vertexShader, fragmentShader: string): uint =
    var program: uint = glCreateProgram()
    var vs: uint = compileShader(GL_VERTEX_SHADER.uint, vertexShader)
    var fs: uint = compileShader(GL_FRAGMENT_SHADER.uint, fragmentShader)
    glAttachShader(program.GLuint, vs.GLuint)
    glAttachShader(program.GLuint, fs.GLuint)
    result = program


var shader: uint
var renderer = newSystem()

renderer.matchComponent(Position)
renderer.matchComponent(Dimensions)
renderer.matchComponent(RenderBlock)


renderer.init = proc(system: System) =

    var positions: array = [
        -0.5, -0.5,
        0.0, 0.5,
        0.5, -0.5
    ]

    var buffer: GLuint = 0
    glGenBuffers(1, addr(buffer))
    glBindBuffer(GL_ARRAY_BUFFER, buffer)
    glBufferData(GL_ARRAY_BUFFER, sizeof(positions).GLsizeiptr, addr(
            positions), GL_STATIC_DRAW)

    glVertexAttribPointer(0.GLuint, 2.GLint, cGL_FLOAT, GL_FALSE, (
        sizeof(float) * 2).GLsizei, cast[pointer](0))

    glEnableVertexAttribArray(0.GLuint)

    var vertexShader: string = """
        #version 330 core
        layout(location=0) in vec4 position;
        void main() {
            gl_Position = position;
        }
        """
    var fragmentShader: string = """
        #version 330 core
        layout(location = 0) out vec4 color;
        void main() {
            color = vec4(1.0, 1.0, 1.0, 1.0);
        }
        """

    shader = createShader(vertexShader, fragmentShader)

    glLinkProgram(shader.GLuint)


renderer.render = proc(system: System) =
    for entity in entitiesForSystem(system):

        var pos = entity.get(Position)
        var dim = entity.get(Dimensions)

        # var positions: array = [
        #     Vertex(x: pos.x.GLfloat, y: pos.y.GLfloat),
        #     Vertex(x: (pos.x + dim.width).GLfloat, y: (pos.y +
        #             dim.height).GLfloat),
        #     Vertex(x: pos.x.GLfloat, y: (pos.y + dim.height).GLfloat)
        # ]

        echo("rendering entity")

        glUseProgram(shader.GLuint)

        glDrawArrays(GL_TRIANGLES, 0, 3)


ecs.add(renderer)
