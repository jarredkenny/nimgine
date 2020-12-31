import random, strformat, sequtils, sugar
import perlin, glm, memo

import ../types
import ./mesh
import ./marchingcubes


type
  Chunk[S: static[int]] = array[0..S-1, array[0..S-1, array[0..S-1, Block]]]

  Block* = ref object
    active*: bool


randomize()

let seed = rand(99999999).uint32

proc generateTerrainChunk(chunkX, chunkZ, size, density, octaves: int, amplitude, spreadX, spreadZ, persistence: float): Mesh {.memoized.} =

  var vertices = newSeq[Vertex]()
  var indices = newSeq[uint32]()
  var textures = newSeq[Texture]()
  let noise = newNoise(seed, octaves, persistence)

  var den = density

  # Generate Vertices
  for z in 0..den:
    for x in 0..den:
        var scaledX = (x.float - (den / 2)) / den.float
        var scaledZ = (z.float - (den / 2)) / den.float
        var nX = (scaledX * size.float) + (size.float * chunkX.float)
        var nZ = scaledZ * size.float + (size.float * chunkZ.float)
        var rX = nX * (1  / (spreadX.float / 60))
        var rZ = nZ * ( 1 / (spreadZ.float / 60))
        var h = noise.perlin(rX, rZ, 0.0)

        h = (h - 0.5) * 2

        var height = h * amplitude.float
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




proc newTerrainModel*(terrain: Terrain, viewer: Transform, rd: int): Model =

  let chunkX = (viewer.translation.x / terrain.size.float32).int
  let chunkZ = (viewer.translation.z / terrain.size.float32).int

  var chunks = newSeq[Mesh]()

  for cX in countup(chunkX - rd, chunkX + rd):
    for cZ in countup(chunkZ - rd, chunkZ + rd):

      let distance = sqrt(pow((chunkX - cX).float, 2) + pow((chunkZ - cZ).float, 2))
      let density = if distance < 2.0: terrain.density else: (terrain.density.float / (distance)).int

      var chunk = generateTerrainChunk(
        cX,
        cZ,
        terrain.size,
        density,
        terrain.octaves,
        terrain.amplitude,
        terrain.spreadX,
        terrain.spreadZ,
        terrain.persistence
      )
      chunks.add(chunk)

  result = newModel(chunks)


proc circle_function(x, y, z: int): float =
  sqrt(x.float * x.float + y.float * y.float + z.float * z.float)

proc single_cell(x, y, z: int): Mesh =

    var noise: array[8, float]

    for v in 0..<8:
        let pos = VERTICES[v]
        noise[v] = circle_function(x + pos[0], y + pos[1], z + pos[2])

    var match: int = 0

    for v in 0..<8:
        if noise[v] > 0:
            match += pow(2, v.float).int

    let faces = CASES[match]
    

    echo repr(faces)


    proc edge_to_boundary_vertex(edge: int): Vertex =
        let v0 = EDGES[edge][0]
        let v1 = EDGES[edge][1]
        var f0 = noise[v0]
        var f1 = noise[v1]

        let t0 = 1 - (0 - f0) / (f1 - f0)
        let t1 = 1 - t0

        let vPos0 = VERTICES[v0]
        let vPos1 = VERTICES[v1]

        result = Vertex(
            position: vec3(
                (x.float + vPos0[0].float * t0 + vPos1[0].float * t1).float32,
                (y.float + vPos0[1].float * t0 + vPos1[1].float * t1).float32,
                (z.float + vPos0[2].float * t0 + vPos1[2].float * t1).float32
            ),
            normal: vec3(1.0.float32, 1.0, 1.0)
        )

    var vertices = newSeq[Vertex]()
    var indices = newSeq[uint32]()

    for face in faces:
        let edges = face
        let verts: seq[Vertex] = edges.map(edge => edge_to_boundary_vertex(edge))

        let next_vert_index = len(vertices) + 1

        for i in 0..2:
            indices.add((next_vert_index + 1).uint32)

        for vertex in verts:
            vertices.add(vertex)

    result = newMesh(vertices, indices, @[])


proc generateChunk*(xMin, xMax, yMin, yMax, zMin, zMax: int): Mesh =
    var mesh = Mesh()
    for x in xMin..xMax:
        for y in yMin..yMax:
            for z in zMin..zMax:
                let m = single_cell(x, y, z)
                mesh.extend(m)
    result = mesh