import strformat, strutils

import opengl, glm, assimp

import ../types
import shader

proc uniform*(mesh: Mesh, name: string, matrix: var Mat4) =
  var index: GLint = glGetUniformLocation(mesh.shader.id.GLuint, name)
  glUniformMatrix4fv(index, 1.GLsizei, GL_FALSE, matrix.caddr)

proc use*(mesh: Mesh) =
  mesh.shader.use()
  glBindVertexArray(mesh.vao.GLuint)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo.GLuint)

proc draw*(mesh: Mesh) =
  glDrawElements(GL_TRIANGLES, (mesh.indices.len * sizeof(mesh.indices[
      0])).GLsizei, GL_UNSIGNED_INT, nil)
  glBindVertexArray(0)


proc loadMaterialTextures*(scene: PScene, mat: PMaterial, kind: TTextureType,
    name: string): seq[Texture] =
  echo "loadMaterialTextures"
  echo fmt"scene.textureCount: {scene.textureCount}"
  for i in 0..<scene.textureCount:
    var str: AIString
    discard mat.getTexture(kind, i, addr(str))
    echo fmt"str: {str}"

proc processMesh(scene: PScene, node: PNode, mesh: PMesh, myMesh: var Mesh) =
  let vertices = cast[ptr UncheckedArray[TVector3d]](mesh.vertices)
  let normals = cast[ptr UncheckedArray[TVector3d]](mesh.normals)

  for i in 0..<mesh.vertexCount:
    let pos = vertices[i]
    let norm = normals[i]
    let vertex = Vertex(
      position: vec3(pos.x, pos.y, pos.z),
      normal: vec3(norm.x, norm.y, norm.z)
    )
    myMesh.vertices.add(vertex)

  for i in 0..<mesh.faceCount:
    let face = mesh.faces[i]
    for k in 0..2:
      myMesh.indices.add(face.indices[k].GLuint)

  echo fmt"mesh.materialIndex: {mesh.materialIndex}"
  if mesh.materialIndex >= 0:
    echo "load a mesh textures"
    var mat: PMaterial = scene.materials[mesh.materialIndex]



proc processNode(scene: PScene, node: PNode, mesh: var Mesh) =
  for i in 0..<node.meshCount:
    processMesh(scene, node, scene.meshes[node.meshes[i]], mesh)
  for i in 0..<node.childrenCount:
    processNode(scene, node.children[i], mesh)

proc loadModel*(file: string, mesh: var Mesh) =
  echo fmt"loading model for mesh: {repr(mesh)}"

  let scene = assimp.aiImportFile(file,
    aiProcess_MakeLeftHanded or
    aiProcess_FlipWindingOrder or
    aiProcess_FlipUVs or
    aiProcess_PreTransformVertices or
    aiProcess_GenSmoothNormals or
    aiProcess_Triangulate or
    aiProcess_FixInfacingNormals or
    aiProcess_FindInvalidData or
    aiProcess_ValidateDataStructure or 0
  )

  if isNil scene:
    echo fmt"Failed to load model: {file}"
  else:
    echo fmt"Sucessfully loaded file {file}"

  echo fmt"Scene: {scene.meshCount} meshes"
  echo fmt"Animations: {scene.animationCount > 0}"

  # start processing the model
  processNode(scene, scene.rootNode, mesh);

proc init*(mesh: var Mesh) =

  if mesh.initialized:
    raise newException(Exception, "mesh is already initialized")

  if mesh.file.len == 0:
    return

  loadModel(mesh.file, mesh)
  mesh.model = mat4(1.GLfloat)
  mesh.shader = newShader(
    """
    #version 440 core
    in vec3 position;
    in vec3 normal;
    in vec2 tc;
    out vec3 fragmentColor;
    out vec2 textureCoord;
    uniform mat4 MVP;
    void main() {
        fragmentColor = normal;
        textureCoord = tc * vec2(1.0, 1.0);
        gl_Position = MVP * vec4(position, 1.0);
    }
    """,
    """
    #version 440 core
    in vec3 fragmentColor;
    in vec2 textureCoord;
    out vec4 color;
    out vec2 textCoordOut;
    void main() {
      color = vec4(fragmentColor, 1.0);
      textCoordOut = textureCoord;
    }
    """
    )


  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  mesh.vao = vao

  var vbo: GLuint
  glGenBuffers(1, vbo.addr)

  var ebo: Gluint
  glGenBuffers(1, ebo.addr)
  mesh.ebo = ebo

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)

  glBufferData(GL_ARRAY_BUFFER, (sizeof(mesh.vertices[0]) *
      mesh.vertices.len).GLsizeiptr, mesh.vertices[0].addr, GL_STATIC_DRAW)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, (sizeof(GLuint) *
      mesh.indices.len).GLsizeiptr, mesh.indices[0].addr, GL_STATIC_DRAW)

  let stride: GLsizei = sizeof(mesh.vertices[0]).GLsizei

  let posAttr: GLuint = glGetAttribLocation(mesh.shader.id.GLuint,
      "position".cstring).GLuint
  let tcAttr: Gluint = glGetAttribLocation(mesh.shader.id.GLuint,
      "tc".cstring).GLuint
  let normAttr: GLuint = glGetAttribLocation(mesh.shader.id.GLuint,
      "normal".cstring).GLuint

  # Position
  glVertexAttribPointer(posAttr, 3.GLint, cGL_FLOAT, GL_FALSE, stride, cast[
      pointer](offsetOf(Vertex, position)))
  glEnableVertexAttribArray(posAttr)

  # Normal
  glVertexAttribPointer(normAttr, 3.GLint, cGL_FLOAT, GL_FALSE, stride, cast[
      pointer](offsetOf(Vertex, normal)))
  glEnableVertexAttribArray(normAttr)

  # Texture Coordinates
  glVertexAttribPointer(tcAttr, 2.GLint, cGL_FLOAT, GL_FALSE, stride,
      cast[pointer](offsetOf(Vertex, texCoord)))
  glEnableVertexAttribArray(tcAttr)

  mesh.initialized = true
