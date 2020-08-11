import types
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

proc newPosition*(x, y, z: float): Position =
  var position: Position = newComponent(Position)
  position.x = x
  position.y = y
  position.z = z
  result = position

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