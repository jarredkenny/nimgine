import sequtils, math, deques, tables
import opengl
import glm

type

  VertexBuffer* = ref object
    id*: uint
    vertices*: seq[float]
    name*: string
    layout*: AttributeLayout

  IndexBuffer* = ref object
    id: uint
    indices: seq[int]

  AttributeLayout* = ref object
    size, stride, offset: int

  Shader* = ref object
    id*: uint
    attributes: Table[string, AttributeLayout]

  Mesh* = ref object
    vao: uint
    buffers: seq[VertexBuffer]
    elements: IndexBuffer
    shader: Shader

  Camera* = ref object
    projection*: Mat4[GLfloat]
    view*: Mat4[GLfloat]

  Scene* = ref object
    camera*: Camera
    drawQueue: Deque[Mesh]

proc newVertexBuffer*(name: string, vertices: seq[float], size, stride,
    offset: int): VertexBuffer =
  var layout = AttributeLayout(size: size, stride: stride, offset: offset)
  var vb = VertexBuffer(name: name, vertices: vertices, layout: layout)
  result = vb


proc newIndexBuffer*(indices: seq[int]): IndexBuffer =
  result = IndexBuffer(indices: indices)

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

proc use*(shader: Shader) =
  glUseProgram(shader.id.GLuint)

proc newMesh*(buffers: seq[VertexBuffer], elements: IndexBuffer,
    shader: Shader): Mesh =
  result = Mesh(buffers: buffers, elements: elements, shader: shader)


proc init*(mesh: Mesh) =

  # Init Vertex Buffers
  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  mesh.vao = vao

  for buffer in mesh.buffers:

    echo("Creating buffer " & $buffer.name)

    var vertices: seq[GLfloat] = buffer.vertices.mapIt(it.GLfloat)

    echo(vertices)

    var vbo: GLuint
    glGenBuffers(1, vbo.addr)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)

    glBufferData(
      GL_ARRAY_BUFFER,
      (sizeof(GLfloat) * vertices.len).GLsizeiptr,
      vertices[0].addr,
      GL_STATIC_DRAW
    )

    echo("Populated buffer")
    echo("Setting layout")

    var id: GLint = glGetAttribLocation(mesh.shader.id.GLuint, buffer.name)

    echo("Location for " & $buffer.name & " is " & $id)

    # glEnableVertexAttribArray(id.GLuint)
    # glVertexAttribPointer(id.GLuint, buffer.layout.size.GLint, cGL_FLOAT,
    #   GL_FALSE, (sizeof(
    #   GLfloat) * buffer.layout.stride).GLsizei, cast[pointer](sizeof(
    #       GLfloat) * buffer.layout.offset))

  # Init Index Buffer
  var ebo: GLuint
  var indices = mesh.elements.indices.mapIt(it.GLint)
  glGenBuffers(1, ebo.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(
    GL_ELEMENT_ARRAY_BUFFER,
    (sizeof(GLint) * indices.len).GLsizeiptr,
    addr(indices[0]),
    GL_STATIC_DRAW
  )
  mesh.elements.id = ebo

proc uniform(mesh: Mesh, name: string, matrix: var Mat4) =
  var index: GLint = glGetUniformLocation(mesh.shader.id.GLuint, name)
  glUniformMatrix4fv(index, 1.GLsizei, GL_FALSE, matrix.caddr)

proc use(mesh: Mesh) =
  mesh.shader.use()
  glBindVertexArray(mesh.vao.GLuint)
  mesh.elements.use()

proc draw(mesh: Mesh) =
  mesh.elements.draw()

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
    mesh.uniform("MVP", mvp)
    mesh.draw()
