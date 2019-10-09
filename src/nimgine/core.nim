import platform
import timing
import events
import ecs

type Position = ref object of Component
  x, y: int

var clock: Clock = newClock()
var running: bool = true

proc init() =
  ecs.init()
  platform.init()

proc update() =
  clock.update()
  platform.update()
  for event in pollEvent():
    ecs.update(event, clock.dt)
    if event.kind == Quit:
      running = false

proc render() =
  ecs.render()
  platform.render()

proc loop() =
  while running:
    update()
    render()

proc initGame*() =

  var testSystem = newSystem()
  var testEntity = newEntity()
  var testComponent = newComponent()

  testSystem.update = proc(system: System, event: Event, entity: Entity, dt: float) =
    echo($event & " -> " & $entity)
    echo(entity.get(Position))

  testSystem.subscribe(@[Input])
  testSystem.matchComponents(@["Position"])

  ecs.add(testSystem)

  testEntity.add(Position())
  ecs.add(testEntity)

  init()
  loop()
