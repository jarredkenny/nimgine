import nimgine/[core, ecs, events]

type
  Position = ref object of Component
    x, y: int

  Controllable = ref object of Component


let player: Entity = newEntity()
player.add(Position())
player.add(Controllable())

let controller: System = newSystem()
controller.subscribe(Update)
controller.matchComponent(Controllable)
controller.matchComponent(Position)

controller.update = proc(sys: System, evt: Event, ent: Entity, dt: float) =
  echo "Test system update based on " & $evt
  var position = ent.get(Position)
  echo("x: " & $position.x & "   y: " & $position.y)

ecs.add(player)
ecs.add(controller)

initGame()
