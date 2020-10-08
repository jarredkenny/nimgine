# import math
import nimgine/[types, core, ecs, renderer]

let app: Application = newApplication()

var camera = newEntity()
camera.add(Camera())
camera.add(Controllable())
camera.add(newTransform(1.float, 0.float, -12.float))
app.world.add(camera)

const MODELS = @[
  "models/Collada/teapots.DAE",
  "models/airboat.obj"
]

const PADDING = 10;

let C = 0;

for x in 0..C:
  for y in 0..C:
    for z in 0..C:
      var e = newEntity()
      e.add(newTransform((PADDING * + (x * PADDING)).float, (PADDING + (y * PADDING)).float, (-PADDING + (z * PADDING)).float))
      e.add(newModel(MODELS[z mod 2]))
      app.world.add(e)

app.start()
