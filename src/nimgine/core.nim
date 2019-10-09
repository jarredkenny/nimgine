import platform
import timing
import events
import ecs

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

  testSystem.subscribe(@[Input])
  testSystem.matchComponents(@["Component"])

  ecs.add(testSystem)

  testEntity.add(testComponent)

  ecs.add(testEntity)

  # entitiesForSystem(testSystem)

  init()
  loop()
