import strformat
import opengl, glm
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
  glUseProgram(shader.id.GLuint)

proc setBool*(shader: Shader, location: string, value: bool) =
  glUniform1i(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, value.GLint)

proc setInt*(shader: Shader, location: string, value: int32) =
  glUniform1i(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, value.GLint)

proc setFloat*(shader: Shader, location: string, value: float32) =
  glUniform1f(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, value.GLfloat)

proc setVec2*(shader: Shader, location: string, value: var Vec2f) =
  glUniform2fv(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, 1, value.caddr)

proc setVec3*(shader: Shader, location: string, value: var Vec3f) =
  glUniform3fv(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, 1, value.caddr)

proc setVec4*(shader: Shader, location: string, value: var Vec4f) =
  glUniform4fv(glGetUniformLocation(shader.id.GLuint, location.cstring).GLint, 1, value.caddr)

proc setMat4*(shader: Shader, name: string, matrix: var Mat4) =
  glUniformMatrix4fv(glGetUniformLocation(shader.id.GLuint, name), 1.GLsizei, GL_FALSE, matrix.caddr)

