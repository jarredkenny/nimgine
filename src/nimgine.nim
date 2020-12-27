import glm
import nimgine/[types, core, ecs, renderer, debug]
let app: Application = newApplication()

var camera = newEntity()
camera.set(Camera())
camera.set(Controllable())

var cameraTransform = newTransform(0, 80, 0)

cameraTransform.rotation.x = 0
cameraTransform.rotation.y = -90

camera.set(cameraTransform)
app.world.add(camera)

const MODELS = @[
  "models/Collada/teapots.DAE",
  "models/airboat.obj"
]


let t = newEntity()
let terrain = Terrain(
  size: terrainSize.int,
  density: terrainDensity.int,
  octaves: terrainOctaves.int,
  amplitude: terrainAmp,
  spreadX: terrainSpreadX,
  spreadZ: terrainSpreadZ,
  persistence: terrainPersistence
)
let terrainTrans = newTransform(0.float32, -30, 0)

t.set(terrain)
t.set(newTerrainModel(terrain, Transform(), 1))
t.set(terrainTrans)

app.world.add(t)

app.start()