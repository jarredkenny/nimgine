import nimgine/[types, core, ecs]

let app: Application = newApplication()

let boat: Entity = newEntity()
boat.add(newPosition(0, 0, 0))
boat.add(newComponent(Dimensions))
boat.add(newMesh("models/airboat.obj"))

let floor: Entity = newEntity();
floor.add(newPosition(0, 5, 0))
floor.add(newComponent(Dimensions))
floor.add(newMesh("models/airboat.obj"))

let camera: Entity = newEntity()
camera.add(Position(x: 0, y: 0, z: 0))
camera.add(ControlledCamera())

app.world.add(@[camera, boat, floor])

app.start()
