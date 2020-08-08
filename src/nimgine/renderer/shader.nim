import opengl
import ../types

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

proc newShader*(vertexShader, fragmentShader: string): Shader =
  var id: uint = glCreateProgram()
  var vs: uint = compileShader(GL_VERTEX_SHADER.uint, vertexShader)
  var fs: uint = compileShader(GL_FRAGMENT_SHADER.uint, fragmentShader)
  glAttachShader(id.GLuint, vs.GLuint)
  glAttachShader(id.GLuint, fs.GLuint)
  glLinkProgram(id.GLuint)
  glValidateProgram(id.GLuint)
  result = Shader(id: id)

proc use*(shader: Shader) =
  # echo fmt"binding shader: {shader.id}"
  glUseProgram(shader.id.GLuint)
