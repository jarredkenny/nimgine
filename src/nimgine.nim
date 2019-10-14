import nimgine/[core, ecs, events, components]

let world: World = newWorld()

let player: Entity = newEntity()
player.add(Position(x: 0, y: 0))
player.add(Dimensions(width: 20, height: 20))
player.add(RenderBlock())

let camera: Entity = newEntity()
camera.add(Position(x: 0, y: 0, z: 40))
camera.add(Controllable())
camera.add(ControlledCamera())

world.add(@[camera, player])

world.start()
