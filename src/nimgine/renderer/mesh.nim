import strformat, strutils, tables, os

import opengl, glm, assimp
import stb_image/read as stbi

import ../types
import shader

var loadedMeshes* = initTable[string, Mesh]()

var meshCount*: uint = 0
var drawCalls*: uint = 0

proc loadTextureWithMips(file: string, gammaCorrection: bool): uint32 =
  var textureId: GLuint
  glGenTextures(1.GLsizei, addr textureId)
  glBindTexture(GL_TEXTURE_2D, textureId)

  stbi.setFlipVerticallyOnLoad(true)               
  var width,height,channels:int  

  let path = normalizedPath(file.replace("\\", "/"))

  echo fmt"Loading Texture: {path} as texture id {textureId}"

  let data = stbi.load(path,width,height,channels,stbi.Default)      

  if data.len != 0:
      let gammaFormat = 
          if gammaCorrection: 
              GL_SRGB 
          else: 
              GL_RGB
              
      let (internalFormat, dataFormat, param) = 
          if channels == 1:                    
              (GL_RED,GL_RED,GL_REPEAT)
          elif channels == 3:                    
              (gammaFormat, GL_RGB,GL_REPEAT)
          elif channels == 4:
              (gammaFormat, GL_RGBA,GL_CLAMP_TO_EDGE)
          else:            
              ( echo "texture unknown, assuming rgb";        
                      (GL_RGB,GL_RGB,GL_REPEAT) )

      glTexImage2D(
        GL_TEXTURE_2D,
        0.GLint,
        internalFormat.GLint,
        width.GLsizei,
        height.GLsizei,
        0,
        dataFormat,
        GL_UNSIGNED_BYTE,
        data[0].unsafeaddr
      )

      glGenerateMipmap(GL_TEXTURE_2D)   

     
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,param)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,param)            
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR)
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)               
      
      return textureId
  else:
      echo "Failure to Load Image"            
      return 0


proc init*(mesh: var Mesh) =

  mesh.shader = newShader(
    """
    #version 330 core
    layout (location = 0) in vec3 position;
    layout (location = 1) in vec3 normal;
    layout (location = 2) in vec2 tc;

    out vec2 textureCoord;

    uniform mat4 MVP;
    uniform sampler2D TextureDiffuse1;

    void main() {
      gl_Position = MVP * vec4(position, 1.0);
      textureCoord = tc;
    }
    """,
    """
    #version 330 core
    out vec4 FragColor;

    in vec2 textureCoord;

    uniform sampler2D TextureDiffuse1;

    void main()
    {    
      FragColor = texture(TextureDiffuse1, textureCoord);
    }
    """
  )


  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  mesh.vao = vao

  var vbo: GLuint
  glGenBuffers(1, vbo.addr)
  mesh.vbo = vbo

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

  echo fmt"stride: {stride}"

  let posAttr: GLuint = glGetAttribLocation(mesh.shader.id.GLuint,
      "position".cstring).GLuint
  let normAttr: GLuint = glGetAttribLocation(mesh.shader.id.GLuint,
      "normal".cstring).GLuint
  let tcAttr: Gluint = glGetAttribLocation(mesh.shader.id.GLuint,
      "tc".cstring).GLuint

  # Position
  echo fmt"posAttr: {posAttr}"
  glVertexAttribPointer(posAttr, 3.GLint, cGL_FLOAT, GL_FALSE, stride, cast[
      pointer](offsetOf(Vertex, position)))
  glEnableVertexAttribArray(posAttr)

  # Normal
  echo fmt"normAttr: {normAttr}"
  # glVertexAttribPointer(normAttr, 3.GLint, cGL_FLOAT, GL_FALSE, stride, cast[
  #     pointer](offsetOf(Vertex, normal)))

  # glEnableVertexAttribArray(normAttr)

  # # Texture Coordinates
  echo fmt"tcAttr: {tcAttr}"
  glVertexAttribPointer(tcAttr, 2.GLint, cGL_FLOAT, GL_FALSE, stride, cast[pointer](offsetOf(Vertex, texCoord)))

  glEnableVertexAttribArray(tcAttr)


proc newMesh*(vertices: seq[Vertex], indices: seq[uint32], textures: seq[Texture]): Mesh =
  var mesh = Mesh(vertices: vertices, indices: indices, textures: textures)
  result = mesh

proc loadMaterialTextures(model: Model, mat: PMaterial, texType: TTextureType, typeName: TextureType): seq[Texture] =
  var textures = newSeq[Texture]()
  let texCount = getTextureCount(mat, texType).int
  
  for i in 0..pred(texCount):
    var str: AIString
    let ret = getTexture(mat, texType, i.cint, str.addr)
    if ret == ReturnFailure:
      echo "failed to get texture"

    textures.add(Texture(
      id: loadTextureWithMips(model.directory & $str, true),
      kind: typeName,
      path: $str
    ))

  return textures

proc processMesh(model: Model, mesh: PMesh, scene: PScene): Mesh =

  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()

  let meshVertices = cast[ptr UncheckedArray[TVector3d]](mesh.vertices)
  let meshNormals = cast[ptr UncheckedArray[TVector3d]](mesh.normals)

  # Vertices
  for i in 0..<pred(mesh.vertexCount.int):
    let pos = meshVertices[i]
    let norm = meshNormals[i]

    var tc: Vec2[Point] = vec2(0.0.Point, 0.0)

    if mesh.texCoords[0] != nil:
      var m = cast[ptr UncheckedArray[TVector3d]](mesh.texCoords[0])
      tc.x = m[i].x
      tc.y = m[i].y


    let vertex = Vertex(
      position: vec3(pos.x, pos.y, pos.z),
      normal: vec3(norm.x, norm.y, norm.z),
      texCoord: vec2(tc.x, tc.y)
    )

    vertices.add(vertex)

  # Indices
  for i in 0..<pred(mesh.faceCount.int):
    let face = mesh.faces[i]
    for k in 0..2:
      indices.add(face.indices[k].GLuint)

  let material = scene.materials[mesh.materialIndex]

  let diffuseMaps = loadMaterialTextures(model, material, TTextureType.TexDiffuse, TextureType.TextureDiffuse)
  let specularMaps = loadMaterialTextures(model, material, TTextureType.TexSpecular, TextureType.TextureSpecular)
  let normalMaps = loadMaterialTextures(model, material, TTextureType.TexNormals, TextureType.TextureNormal)
  let heightMaps = loadMaterialTextures(model, material, TTextureType.TexHeight, TextureType.TextureHeight)

  textures = diffuseMaps & specularMaps & normalMaps & heightMaps

  var mesh = newMesh(vertices, indices, textures)
  mesh.init()
  result = mesh


proc processNode(model:var Model, node:PNode, scene:PScene) = 
    let meshCount = node.meshCount.int    
    for i in 0 .. pred(meshCount):
        model.meshes.add(processMesh(model,scene.meshes[node.meshes[i]],scene))
    let childrenCount = node.childrenCount.int
    for i in 0 .. pred(childrenCount):
        processNode(model,node.children[i],scene)

proc newModel*(file: string): Model =
  result = Model(file: file, initialized: false)

proc init*(model: var Model) =
  if model.initialized:
    raise newException(Exception, "mesh is already initialized")

  if model.file.len == 0:
    return

  meshCount += 1

  echo fmt"Loading Model: {model.file}"

  let scene = assimp.aiImportFile(model.file,
    aiProcess_MakeLeftHanded or
    aiProcess_FlipWindingOrder or
    aiProcess_FlipUVs or
    # aiProcess_PreTransformVertices or
    aiProcess_GenSmoothNormals or
    aiProcess_Triangulate or
    aiProcess_FixInfacingNormals or
    aiProcess_FindInvalidData or
    aiProcess_ValidateDataStructure or 0
  )

  if isNil scene:
    echo fmt"Failed to load model: {model.file}"

  model.directory = model.file.substr(0,model.file.rfind("/"))

  processNode(model, scene.rootNode, scene);

  model.initialized = true
 
proc use(mesh: Mesh) =
  mesh.shader.use()
  glBindVertexArray(mesh.vao.GLuint)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo.GLuint)

proc draw(mesh: Mesh) =
  drawCalls += 1
  var diffuseNr, specularNr, normalNr, heightNr = 0.uint32

  for i, tex in mesh.textures:
    var activeTex = (GL_TEXTURE0.ord + i).GLenum
    echo fmt"active tex: {repr(activeTex)}"
    glActiveTexture(activeTex)
    let texIndex =
      case tex.kind:
        of TextureDiffuse:
          diffuseNr.inc()
          diffuseNr
        of TextureSpecular:
            specularNr.inc()
            specularNr
        of TextureNormal:
            normalNr.inc()
            normalNr
        of TextureHeight:
            heightNr.inc()
            heightNr
    let uniform = $tex.kind & $texIndex
    echo fmt"setting {uniform} in shader"
    mesh.shader.setInt(uniform, i.int32)
    glBindTexture(GL_TEXTURE_2D, mesh.textures[i].id.GLuint)

  glDrawElements(GL_TRIANGLES, (mesh.indices.len * sizeof(mesh.indices[
      0])).GLsizei, GL_UNSIGNED_INT, nil)

  glBindVertexArray(0)
  glActiveTexture(GL_TEXTURE0)



proc draw*(model: Model, mvp: var Mat4[GLfloat]) =
  for mesh in model.meshes:
      mesh.use()
      mesh.shader.setMat4("MVP", mvp)
      mesh.draw()