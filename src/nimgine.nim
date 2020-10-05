import nimgine/[types, core, ecs]

let app: Application = newApplication()

var camera = newEntity()
camera.add(Camera())
camera.add(Controllable())
camera.add(newTransform(1.float, 0.float, -12.float))
app.world.add(camera)

let C = 1;

for x in 0..C:
  for y in 0..C:
    for z in 0..C:
      var e = newEntity()
      e.add(newTransform((24 + (x * 24)).float, (-10 + (y * 18)).float, (-10 + (z * 22)).float))
      e.add(newMesh("models/airboat.obj"))
      app.world.add(e)

app.start()
