import ../types

proc newVertexBuffer*(name: string, vertices: seq[float], size, stride,
    offset: int): VertexBuffer =
  var layout = AttributeLayout(size: size, stride: stride, offset: offset)
  var vb = VertexBuffer(name: name, vertices: vertices, layout: layout)
  result = vb

proc newIndexBuffer*(indices: seq[int]): IndexBuffer =
  result = IndexBuffer(indices: indices)
