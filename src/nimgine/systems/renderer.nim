import opengl

import ../ecs
import ../components

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
    glBindFragDataLocation(program.GLuint, 0, "color");
    result = program


var shader: uint
var renderer = newSystem()

renderer.matchComponent(Position)
renderer.matchComponent(Dimensions)
renderer.matchComponent(RenderBlock)


renderer.init = proc(system: System) =
    echo("renderer - init")

    var positions: array = [
        0.0, 0.5,
        0.5, -0.5,
        -0.5, -0.5
    ]

    var vao: GLuint;
    glGenVertexArrays(1, addr(vao))
    glBindVertexArray(vao)

    var buffer: GLuint = 0
    glGenBuffers(1, addr(buffer))
    glBindBuffer(GL_ARRAY_BUFFER, buffer)

    var vertexShader: string = """
        #version 330 core
        layout(location = 0) in vec2 position;
        void main() {
            gl_Position = vec4(position, 0.0, 1.0);
        }
        """
    var fragmentShader: string = """
        #version 330 core
        layout(location=0) out vec4 color;
        void main() {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        }
        """

    shader = createShader(vertexShader, fragmentShader)
    glLinkProgram(shader.GLuint)
    glUseProgram(shader.GLuint)

    var posAttrib: GLint = glGetAttribLocation(shader.GLuint, "position")

    glVertexAttribPointer(posAttrib.GLuint, 2.GLint, cGL_FLOAT, GL_FALSE,
    sizeOf(positions).GLsizei, cast[pointer](0))

    glEnableVertexAttribArray(posAttrib.GLuint)

    glBufferData(GL_ARRAY_BUFFER, sizeof(positions).GLsizeiptr, addr(positions), GL_STATIC_DRAW)

renderer.render = proc(system: System) =
    echo("renderer - render")
    glDrawArrays(GL_TRIANGLES, 0, 3)

ecs.add(renderer)
