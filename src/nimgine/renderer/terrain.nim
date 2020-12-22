import random, strformat
import perlin, glm, memo

import ../types
import ./mesh


randomize()

let noise = newNoise()

proc generatePlane(size, density, amplitude, spread: int): Mesh {.memoized.} =
  echo "Regenerating terrain model"
  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()

  var den = density

  # Generate Vertices
  for z in 0..den:
    for x in 0..den:

        var scaledZ = (z.float - (den / 2)) / den.float
        var scaledX = (x.float - (den / 2)) / den.float

        var nZ = scaledZ * size.float
        var nX = scaledX * size.float

        var h = noise.perlin(nX * (1  / (spread.float /  50)), (nZ * ( 1 / (spread.float / 50))))

        var height = (h * amplitude.float) - (h * (amplitude.float * 0.5))

        vertices.add(Vertex(
            position: vec3(
                nX.float32,
                height.float32,
                nZ.float32,
            ),
        ))

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


proc newTerrainMesh*(size, density, amplitude, spread: int): Mesh =
  result = generatePlane(size, density, amplitude, spread)


proc newTerrainMesh*(terrain: Terrain): Mesh =
  result = generatePlane(terrain.size.int, terrain.density.int, terrain.amplitude.int, terrain.spread.int)