import nimgine/[core, ecs, events, components]

let player: Entity = newEntity()

player.add(Position(x: 0, y: 0))
player.add(Dimensions(width: 10, height: 10))
player.add(RenderBlock())
player.add(Controllable())

ecs.add(player)

core.init()
