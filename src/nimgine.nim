import nimgine/[core, ecs, events, components]

let world: World = newWorld()

let player: Entity = newEntity()
player.add(Position())
player.add(Dimensions())
player.add(RenderBlock())

let camera: Entity = newEntity()
camera.add(Position(x: 20, y: 20, z: 40))
camera.add(Controllable())
camera.add(ControlledCamera())

world.add(@[camera, player])

world.start()
