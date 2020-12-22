import glm
import nimgine/[types, core, ecs, renderer]

import random
import perlin

let app: Application = newApplication()

# randomize()
let noise = newNoise()

var camera = newEntity()
camera.add(Camera())
camera.add(Controllable())

var cameraTransform = newTransform(0.float, 3, -50)

cameraTransform.rotation.x = -180

camera.add(cameraTransform)
app.world.add(camera)

const MODELS = @[
  "models/Collada/teapots.DAE",
  "models/airboat.obj"
]

proc generatePlane(density: int): Mesh =
  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()

 # Generate Vertices
  for z in 0..density:
    for x in 0..density:

      var height = noise.perlin(x, z) * 10

      vertices.add(Vertex(
        position: vec3(
          ((x.float - (density / 2)) / density.float).float32,
          height.float32,
          ((z.float - (density / 2)) / density.float).float32,
        ),
      ))

  # Generate indices
  for i in 0..<density:
    for start in (((density * i) + i) + 1)..<(((density * i) + i) + density + 1):
      indices.add((start).uint32)
      indices.add((start + density).uint32)
      indices.add((start - 1).uint32)

      indices.add((start).uint32)
      indices.add((start + density + 1).uint32)
      indices.add((start + density).uint32)

  # Calculate face normals
  for index in countup(0, indices.len - 1, 3):
    var vec1 = vertices[indices[index + 1]].position - vertices[indices[index]].position
    var vec2 = vertices[indices[index + 2]].position - vertices[indices[index]].position
    var norm = normalize(cross(vec1, vec2))     
    vertices[indices[index]].normal = norm
    vertices[indices[index + 1]].normal = norm
    vertices[indices[index + 2]].normal = norm

  result = newMesh(vertices, indices, textures)

var terrainMesh = generatePlane(200)

var terrainTransform = newTransform()

terrainTransform.scale.x = 200
terrainTransform.scale.y = 2
terrainTransform.scale.z = 200

terrainTransform.rotation.z = 0

terrainTransform.translation.y = -20.0

let terrain = newEntity()
terrain.add(terrainTransform)
terrain.add(newModel(terrainMesh))

app.world.add(terrain)

app.start()
