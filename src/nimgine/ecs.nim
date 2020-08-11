import glm, opengl

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
export newPosition
export newMesh


proc newCamera*(): Entity =
  result = newEntity()
  result.add(newOrientation())
  result.add(Camera(
    position: vec3(0.GLfloat, 0, 0),
    worldUp: vec3(0.GLfloat, 1, 0),
  ))


var WorldLayer* = ApplicationLayer(
  init: init,
  handle: handle,
  update: update,
  preRender: preRender,
  render: render
)