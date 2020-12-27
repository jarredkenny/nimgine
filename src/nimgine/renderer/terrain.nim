import random, strformat
import perlin, glm, memo

import ../types
import ./mesh


randomize()


var highH, lowH: float = 0.0
let seed = rand(99999999).uint32

let colors = Texture(
  kind: TextureType.TextureDiffuse,
  path: "textures/terrain.png"
)


proc generateTerrainMesh(size, density, octaves: int, amplitude, spreadX, spreadZ, persistence: float): Mesh {.memoized.} =
  echo "Regenerating terrain model"
  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()
  let noise = newNoise(seed, octaves, persistence)

  var den = density

  # textures.add(colors)

  # Generate Vertices
  for z in 0..den:
    for x in 0..den:
        var scaledX = (x.float - (den / 2)) / den.float
        var scaledZ = (z.float - (den / 2)) / den.float
        var nX = scaledX * size.float
        var nZ = scaledZ * size.float
        var rX = nX * (1  / (spreadX.float / 60))
        var rZ = nZ * ( 1 / (spreadZ.float / 60))
        var h = noise.simplex(rX, rZ)

        h = (h - 0.5) * 2

        var height = h * amplitude.float
        vertices.add(Vertex(
            position: vec3(
                nX.float32,
                height.float32,
                nZ.float32,
            ),
            # texCoord: vec2(rX.float32, rZ.float32)
        ))

  echo fmt"low: {lowH} high: {highH}"

  # Generate indices
  for i in 0..<den:
    for start in (((den * i) + i) + 1)..<(((den * i) + i) + den + 1):
      indices.add((start).uint32)
      indices.add((start + den).uint32)
      indices.add((start - 1).uint32)

      indices.add((start).uint32)
      indices.add((start + den + 1).uint32)
      indices.add((start + den).uint32)

  # Calculate face normals
  for index in countup(0, indices.len - 1, 3):
    var vec1 = vertices[indices[index + 1]].position - vertices[indices[index]].position
    var vec2 = vertices[indices[index + 2]].position - vertices[indices[index]].position
    var norm = normalize(cross(vec1, vec2))
    vertices[indices[index]].normal = norm
    vertices[indices[index + 1]].normal = norm
    vertices[indices[index + 2]].normal = norm

  result = newMesh(vertices, indices, textures)


proc newTerrainMesh*(terrain: Terrain): Mesh =
  result = generateTerrainMesh(
    terrain.size,
    terrain.density,
    terrain.octaves,
    terrain.amplitude,
    terrain.spreadX,
    terrain.spreadZ,
    terrain.persistence
  )