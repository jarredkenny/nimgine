import nimgine/[types, core, ecs, events]

let app: Application = newApplication()

let cube: Entity = newEntity()
cube.add(Position())
cube.add(Dimensions())
cube.add(RenderBlock())

let camera: Entity = newEntity()
camera.add(Position(x: 0, y: 0, z: 0))
camera.add(Controllable())
camera.add(ControlledCamera())

app.world.add(@[camera, cube])

app.start()
