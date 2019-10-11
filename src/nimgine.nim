import nimgine/[core, ecs, events, components]

let player: Entity = newEntity()
player.add(Position())
player.add(Controllable())
player.add(RenderBlock())

ecs.add(player)

core.init()
