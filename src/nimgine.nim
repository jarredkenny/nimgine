import nimgine/[types, core, ecs]

let app: Application = newApplication()

var camera = newEntity()
camera.add(Camera())
camera.add(Controllable())
camera.add(newTransform(1.float, 0.float, -12.float))
app.world.add(camera)

for i in 0..5:
  var e = newEntity()
  e.add(newTransform(0.float, (-10 + (i * 5)).float, 0.float))
  e.add(newMesh("models/airboat.obj"))
  app.world.add(e)

app.start()
