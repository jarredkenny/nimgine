import sequtils, math, deques
import opengl
import glm
import sdl2

import types

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
  glDrawElements(GL_TRIANGLES, (sizeof(GLint) * ib.indices.len).GLsizei,
      GL_UNSIGNED_INT, nil)
  glBindVertexArray(0)

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

    var vertices: seq[GLfloat] = buffer.vertices.mapIt(it.GLfloat)

    var vbo: GLuint
    glGenBuffers(1, vbo.addr)
    glBindBuffer(GL_ARRAY_BUFFER, vbo)

    glBufferData(
      GL_ARRAY_BUFFER,
      (sizeof(GLfloat) * vertices.len).GLsizeiptr,
      vertices[0].addr,
      GL_STATIC_DRAW
    )

    var id: GLint = glGetAttribLocation(mesh.shader.id.GLuint, buffer.name)

    glEnableVertexAttribArray(id.GLuint)
    glVertexAttribPointer(id.GLuint, buffer.layout.size.GLint, cGL_FLOAT,
      GL_FALSE, (sizeof(
      GLfloat) * buffer.layout.stride).GLsizei, cast[pointer](sizeof(
          GLfloat) * buffer.layout.offset))

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

proc newCamera(x, y, d, aspect: float): Camera =
  var
    view = lookAt(
      vec3(x.GLfloat, y.GLfloat, d.GLfloat),
      vec3(0.0.GLfloat, 0.0.GLfloat, -4.0.GLfloat),
      vec3(0.0.GLfloat, 1.0.GLfloat, 0.0.GLfloat)
    )
    proj = perspective(65.0.GLfloat, aspect.GLfloat, 0.1.GLfloat,
        1000.0.GLfloat)

  result = Camera(view: view, projection: proj)

proc newScene*(): Scene =
  let scene = Scene()
  scene.drawQueue = initDeque[Mesh]()
  result = scene

proc setCameraPosition*(scene: Scene, x, y, z, aspect: float) =
  scene.camera = newCamera(x, y, z, aspect)

proc submit*(scene: Scene, mesh: Mesh) =
  scene.drawQueue.addLast(mesh)

proc preRender*(scene: Scene) =
  discard

proc render*(app: Application) =
  for mesh in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()

    var model = translate(mat4(1.GLfloat), vec3(0.0.Glfloat, 0.0.GLfloat, -4.0.GLfloat))

    var view = rotate(app.scene.camera.view, (getTicks().float * 0.001).GLfloat,
        vec3(0.7.GLfloat, 0.5.GLfloat, -4.0.GLfloat))

    var mvp = app.scene.camera.projection * view * model

    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()

var RendererLayer* = ApplicationLayer()
RendererLayer.render = render
