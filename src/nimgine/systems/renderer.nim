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
    var vertexShader: string = """
    #version 440 core
    in vec2 position;
    void main() {
        gl_Position = vec4(position, 1.0, 1.0);
    }
    """
    var fragmentShader: string = """
        #version 440 core
        out vec4 color;
        void main() {
            color = vec4(0.0, 0.0, 0.0, 1.0);
        }
        """

    shader = createShader(vertexShader, fragmentShader)
    glLinkProgram(shader.GLuint)


renderer.render = proc(system: System) =
    var positions: array = [
        -0.5.GLfloat, 0.5, # Top Left
        0.5, 0.5,          # Top Right
        0.5, -0.5,         # Botttom Right
        -0.5, -0.5         # Bottom Left
    ]

    var elements: array = [
        0.GLint, 3, 2,
        2, 0, 1
    ]

    var vao, vbo, ebo: GLuint;
    glGenVertexArrays(1, addr(vao))
    glGenBuffers(1, addr(vbo))
    glBindVertexArray(vao)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, (sizeof(GLfloat) *
            positions.len).GLsizeiptr, addr(positions), GL_STATIC_DRAW)
    glGenBuffers(1, addr(ebo))
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (sizeof(GLint) *
            elements.len).GLsizeiptr, addr(elements), GL_STATIC_DRAW)


    var posAttrib: GLint = glGetAttribLocation(shader.GLuint, "position")
    glEnableVertexAttribArray(posAttrib.GLuint)

    glVertexAttribPointer(posAttrib.GLuint, 2.GLint, cGL_FLOAT, GL_FALSE,
            0.GLsizei, nil)

    glUseProgram(shader.GLuint)
    glDrawElements(GL_TRIANGLES, elements.len.GLsizei, GL_UNSIGNED_INT, nil)

    glUseProgram(0)
    glDisableVertexAttribArray(posAttrib.GLuint)

ecs.add(renderer)
