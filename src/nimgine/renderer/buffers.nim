import opengl
import ../types

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
