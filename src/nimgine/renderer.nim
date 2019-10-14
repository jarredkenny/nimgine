import sequtils, math
import opengl
import glm

type

  VertexBuffer* = ref object
    id*: uint
    vertices*: seq[float]

  IndexBuffer* = ref object
    id: uint
    indices: seq[int]

  Shader* = ref object
    id*: uint

  Mesh* = ref object
    vertexBuffer: VertexBuffer
    indexBuffer: IndexBuffer
    shader: Shader

  Camera* = ref object
    projection: Mat4[GLfloat]
    view: Mat4[GLfloat]

  Scene* = ref object
    camera: Camera
    drawQueue: seq[Mesh]

proc newVertexBuffer*(mVertices: seq[float]): VertexBuffer =
  var vao, vbo: GLuint
  var vertices: seq[GLfloat] = mVertices.mapIt(it.GLfloat)
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  glGenBuffers(1, vbo.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(
    GL_ARRAY_BUFFER,
    (sizeof(GLfloat) * vertices.len).GLsizeiptr,
    vertices[0].addr,
    GL_STATIC_DRAW
  )
  result = VertexBuffer(id: vbo, vertices: mVertices)

proc use*(vb: VertexBuffer) =
  glBindBuffer(GL_ARRAY_BUFFER, vb.id.GLuint)

proc newIndexBuffer*(mIndices: seq[int]): IndexBuffer =
  var ebo: GLuint
  var indices = mIndices.mapIt(it.GLint)
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(
    GL_ELEMENT_ARRAY_BUFFER,
    (sizeof(GLint) * indices.len).GLsizeiptr,
    addr(indices[0]),
    GL_STATIC_DRAW
  )
  result = IndexBuffer(id: ebo, indices: mIndices)

proc use*(ib: IndexBuffer) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ib.id.GLuint)

proc draw*(ib: IndexBuffer) =
  glDrawElements(GL_TRIANGLES, ib.indices.len.GLsizei, GL_UNSIGNED_INT, nil)

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
  glBindFragDataLocation(id.GLuint, 0, "color");
  glLinkProgram(id.GLuint)
  result = Shader(id: id)

proc use*(shader: Shader) =
  glUseProgram(shader.id.GLuint)

proc vertIn*(shader: Shader, name: string) =
  var attribId: GLint = glGetAttribLocation(shader.id.GLuint, name)
  glEnableVertexAttribArray(attribId.GLuint)
  glVertexAttribPointer(attribId.GLuint, 2.GLint, cGL_FLOAT, GL_FALSE,
      0.GLsizei, nil)

proc vertIn*(mesh: Mesh, name: string) =
  mesh.shader.vertIn(name)

proc newMesh*(vb: VertexBuffer, ib: IndexBuffer, shader: Shader): Mesh =
  result = Mesh(vertexBuffer: vb, indexBuffer: ib, shader: shader)

proc use(mesh: Mesh) =
  use(mesh.shader)
  use(mesh.vertexBuffer)
  use(mesh.indexBuffer)

proc uniform(mesh: Mesh, name: string, matrix: var Mat4) =
  var index: GLint = glGetUniformLocation(mesh.shader.id.GLuint, name)
  glUniformMatrix4fv(index, 1.GLsizei, GL_FALSE, matrix.caddr)

proc draw(mesh: Mesh) =
  draw(mesh.indexBuffer)

proc newCamera(eye: Vec3, center: Vec3, up: Vec3): Camera =
  var
    view = lookAt(eye, center, up)
    projection = perspective((math.PI/2).GLfloat, 1.0.GLfloat,
    0.01.GLfloat, 100.0.GLfloat)
  result = Camera(view: view, projection: projection)

proc submit*(mesh: Mesh) =
  var
    eye = vec3(0.0.GLfloat, 0.0, 10.0)
    center = vec3(0.0.GLfloat)
    up = vec3(0.0.GLfloat, 1.0, 0.0)
    model = mat4(1.0.GLfloat)
    camera = newCamera(eye, center, up)
    mvp = camera.projection * camera.view * model

  use(mesh)
  mesh.vertIn("position")
  mesh.uniform("MVP", mvp)
  draw(mesh)

proc preRender*() =
  discard

proc render*() =
  discard
