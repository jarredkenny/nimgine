import sequtils, math, deques, tables
import opengl
import glm

type

  VertexBuffer* = ref object
    id*: uint
    vertices*: seq[float]

  IndexBuffer* = ref object
    id: uint
    indices: seq[int]

  AttributeLayout* = ref object
    size, stride, offset: int

  Shader* = ref object
    id*: uint
    attributes: Table[string, AttributeLayout]

  Mesh* = ref object
    vertexBuffer: VertexBuffer
    indexBuffer: IndexBuffer
    shader: Shader

  Camera* = ref object
    projection*: Mat4[GLfloat]
    view*: Mat4[GLfloat]

  Scene* = ref object
    camera*: Camera
    drawQueue: Deque[Mesh]

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
  glLinkProgram(id.GLuint)
  result = Shader(id: id)

proc attribute(shader: Shader, name: string, size, stride, offset: int) =
  var id: GLint = glGetAttribLocation(shader.id.GLuint, name)
  glEnableVertexAttribArray(id.GLuint)
  glVertexAttribPointer(id.GLuint, size.GLint, cGL_FLOAT, GL_FALSE, (sizeof(
      GLfloat) * stride).GLsizei, cast[pointer](sizeof(GLfloat) * offset))

proc attribute(mesh: Mesh, name: string, size, stride, offset: int) =
  mesh.shader.attributes[name] = AttributeLayout(size: size, stride: stride,
      offset: offset)
  mesh.shader.attribute(name, size, stride, offset)

proc use*(shader: Shader) =
  glUseProgram(shader.id.GLuint)

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

proc newCamera(x, y, d: float): Camera =
  var
    eye = vec3(x.GLfloat, y.GLfloat, d.GLfloat)
    center = vec3(0.GLfloat, 0.GLfloat, 0.GLfloat)
    up = vec3(0.0.GLfloat, 1.0, 0.0)
    view = lookAt(eye, center, up)
    projection = perspective((math.PI/2).GLfloat, 1.0.GLfloat,
    0.01.GLfloat, 100.0.GLfloat)
  result = Camera(view: view, projection: projection)

proc newScene*(): Scene =
  let scene = Scene()
  scene.drawQueue = initDeque[Mesh]()
  result = scene

proc setCameraPosition*(scene: Scene, x, y, z: float) =
  echo("new camera position: " & $x & "," & $y & "," & $z)
  scene.camera = newCamera(x, y, z)

proc submit*(scene: Scene, mesh: Mesh) =
  scene.drawQueue.addLast(mesh)

proc preRender*(scene: Scene) =
  discard

proc render*(scene: Scene) =
  for mesh in scene.drawQueue.items:
    scene.drawQueue.popFirst()

    var
      model = mat4(1.0.GLfloat)
      mvp = scene.camera.projection * scene.camera.view * model

    mesh.use()
    mesh.attribute("position", 3, 6, 0)
    mesh.attribute("color", 3, 6, 3)
    mesh.uniform("MVP", mvp)
    mesh.draw()
