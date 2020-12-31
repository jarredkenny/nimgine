import glm
import nimgine/[types, core, ecs, renderer, debug]
let app: Application = newApplication()

var camera = newEntity()
camera.set(Camera())
camera.set(Controllable())

var cameraTransform = newTransform(0, 8, 0)

# cameraTransform.rotation.x = 90
# cameraTransform.rotation.y = 90
# cameraTransform.rotation.z = 1

camera.set(cameraTransform)
app.world.add(camera)

let chunk = generateChunk(-16, 16, -16, 16, -16, 16)
let chunkModel = newModel(chunk)

let terrain = newEntity()
terrain.set(chunkModel)
terrain.set(newTransform(0, 0, 0))

app.world.add(terrain)


# let t = newEntity()

# let nt = Terrain(
#   size: terrainSize.int,
#   density: terrainDensity.int,
#   octaves: terrainOctaves.int,
#   amplitude: terrainAmp,
#   spreadX: terrainSpreadX,
#   spreadZ: terrainSpreadZ,
#   persistence: terrainPersistence
# )

# let terrainTrans = newTransform(0.float32, -30, 0)

# t.set(nT)
# t.set(newTerrainModel(nT, Transform(), 1))
# t.set(terrainTrans)


# app.world.add(t)


app.start()