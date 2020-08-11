import nimgine/[types, core, ecs]

let app: Application = newApplication()

var camera = newCamera()
camera.add(Controllable())
app.world.add(camera)

for i in 0..5:
  var e = newEntity()
  e.add(newPosition(0.float, (-10 + (i * 5)).float, 0.float))
  e.add(newMesh("models/airboat.obj"))
  app.world.add(e)

app.start()
