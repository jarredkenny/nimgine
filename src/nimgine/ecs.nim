import types
import glm
import ecs/[entity, component, system, world]

export newSystem
export subscribe
export matchComponent
export entitiesForSystem
export entityForSystem
export get
export newWorld
export add
export newEntity

proc newTransform*(x, y, z: float32): Transform =
  result = Transform(
    translation: vec3(x, y, z),
    rotation: vec3(0.float32, 0, 1),
    scale: vec3(0.float32, 0, 0)
  )

proc newMesh*(file: string): Mesh =
  var mesh: Mesh = newComponent(Mesh)
  mesh.initialized = false
  mesh.file = file
  result = mesh


var WorldLayer* = ApplicationLayer(
  init: init,
  handle: handle,
  update: update,
  preRender: preRender,
  render: render
)
