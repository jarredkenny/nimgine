import sequtils

import opengl, glm

import ../types
import shader, buffers

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

proc newMesh*(buffers: seq[VertexBuffer], elements: IndexBuffer,
    shader: Shader): Mesh =
  let mesh = Mesh(model: mat4(1.0.GLfloat), buffers: buffers,
      elements: elements, shader: shader)
  mesh.init()
  result = mesh


proc uniform*(mesh: Mesh, name: string, matrix: var Mat4) =
  var index: GLint = glGetUniformLocation(mesh.shader.id.GLuint, name)
  glUniformMatrix4fv(index, 1.GLsizei, GL_FALSE, matrix.caddr)

proc use*(mesh: Mesh) =
  mesh.shader.use()
  glBindVertexArray(mesh.vao.GLuint)
  mesh.elements.use()

proc draw*(mesh: Mesh) =
  mesh.elements.draw()
