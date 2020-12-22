import deques

import glm, opengl

import camera

import ../types

proc newScene*(): Scene =
  let scene = Scene()
  scene.camera = newSceneCamera(0, 0)
  scene.drawQueue = initDeque[(Model, Transform)]()
  result = scene

proc submit*(scene: Scene, model: Model, transform: Transform) =
  scene.drawQueue.addLast((model, transform))

proc preRender*(scene: Scene) =
  scene.camera.calcProjection()
  scene.camera.calcView()
  
proc setCameraDimensions*(scene: Scene, width, height: int) =
  scene.camera.width = width
  scene.camera.height = height

proc setCameraPosition*(scene: Scene, transform: Transform) =
  scene.camera.position = transform.translation
  scene.camera.rotation = transform.rotation
  scene.camera.front = normalize(vec3(
    cos(radians(transform.rotation.x) * cos(radians(transform.rotation.y))),
    sin(radians(transform.rotation.y)),
    sin(radians(transform.rotation.x)) * cos(radians(transform.rotation.y))
  ))

proc calcMVPForMesh*(scene: Scene, model: Model, transform: Transform): Mat4[GLfloat] =
  var model = mat4(1.Point)
  model = translate(model, transform.translation)
  model = rotate(model, radians(transform.rotation.x), vec3(0.0.Point, 1.0, 0.0))
  model = rotate(model, radians(transform.rotation.y), vec3(1.0.Point, 0.0, 0.0))
  model = rotate(model, radians(transform.rotation.z), vec3(0.0.Point, 0.0, 1.0))
  model = scale(model, transform.scale)

  result = scene.camera.projection * scene.camera.view * model
