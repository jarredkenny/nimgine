import glm
import nimgine/[types, core, ecs, renderer, debug]
let app: Application = newApplication()

var camera = newEntity()
camera.add(Camera())
camera.add(Controllable())

var cameraTransform = newTransform(-60.float, 82, -113)

cameraTransform.rotation.x = 80
cameraTransform.rotation.y = -46

camera.add(cameraTransform)
app.world.add(camera)

const MODELS = @[
  "models/Collada/teapots.DAE",
  "models/airboat.obj"
]


let t = newEntity()
let terrain = Terrain(size: terrainSize, density: terrainDensity, amplitude: terrainAmp, spread: terrainSpread)
let terrainTrans = newTransform(0.float32, -30, 0)
t.add(terrain)
t.add(newModel(newTerrainMesh(terrain)))
t.add(terrainTrans)

app.world.add(t)

app.start()