import types, tables
import glm
import ecs/[entity, component, system, world]

import renderer/mesh

export newSystem
export subscribe
export matchComponent
export entitiesForSystem
export entityForSystem
export get
export newWorld
export add
export set
export newEntity

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

var WorldLayer* = ApplicationLayer(
  init: init,
  handle: handle,
  update: update,
  preRender: preRender,
  render: render
)
