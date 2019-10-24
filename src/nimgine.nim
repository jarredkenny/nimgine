import nimgine/[types, core, ecs, events]

let app: Application = newApplication()

let player: Entity = newEntity()
player.add(Position())
player.add(Dimensions())
player.add(RenderBlock())

let camera: Entity = newEntity()
camera.add(Position(x: 0, y: 0, z: 0))
camera.add(Controllable())
camera.add(ControlledCamera())

app.world.add(@[camera, player])

app.start()
