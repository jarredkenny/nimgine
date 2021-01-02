import types, tables
import glm
import ecs/[entity, system, universe]

export add
export matchComponent
export entitiesForSystem
export entityForSystem
export subscribe
export newUniverse
export newEntity
export entitiesWith

proc newTransform*(x, y, z: float32): Transform =
  result = Transform(
    translation: vec3(x, y, z),
    rotation: vec3(0.float32, 0, 1),
    scale: vec3(1.float32, 1, 1)
  )

proc newTransform*(): Transform =
  result = Transform(
    rotation: vec3(0.float32, 0, 1),
    scale: vec3(1.float32, 1, 1)
  )
  
proc newSystem*(sync: bool): System =
  result = System(syncToFrame: sync)

proc newSystem*(): System =
  result = System()

var UniverseLayer* = ApplicationLayer(
  init: proc(app: Application) =
    discard
  ,
  handle: proc(app: Application, event: Event) =
    app.universe.handle(event, app.clock.dtUpdate, app.clock.isFirstInFrame)
  ,
  update: proc(app: Application) =
    app.universe.update(app.clock.dtUpdate, app.clock.isFirstInFrame)
  ,
  preRender: proc(app: Application) =
    app.universe.preRender(app.scene)
  ,
  render: proc(app: Application) =
    app.universe.render(app.scene)
)