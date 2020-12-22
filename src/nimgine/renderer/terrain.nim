import random, strformat
import perlin, glm, memo

import ../types
import ./mesh


randomize()

let noise = newNoise()

proc generatePlane(size, density, amplitude: int): Mesh {.memoized.} =
  echo "Regenerating terrain model"
  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()

 # Generate Vertices
  for z in 0..density:
    for x in 0..density:

        var scaledZ = (z.float - (density / 2)) / density.float
        var scaledX = (x.float - (density / 2)) / density.float

        var nZ = scaledZ * size.float
        var nX = scaledX * size.float

        var h = noise.perlin(nX, nZ)

        var height = h * amplitude.float

        # echo fmt"nZ: {nZ} nX: {nX} h: {h} height: {height}"

        vertices.add(Vertex(
            position: vec3(
                nX.float32,
                height.float32,
                nZ.float32,
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


proc newTerrainMesh*(size, density, amplitude: int): Mesh =
  result = generatePlane(size, density, amplitude)


proc newTerrainMesh*(terrain: Terrain): Mesh =
  result = generatePlane(terrain.size.int, terrain.density.int, terrain.amplitude.int)