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
  scene.camera.front = normalize(vec3(
    cos(radians(transform.rotation.x) * cos(radians(transform.rotation.y))),
    sin(radians(transform.rotation.y)),
    sin(radians(transform.rotation.x)) * cos(radians(transform.rotation.y))
  ))

proc calcMVPForMesh*(scene: Scene, model: Model, transform: Transform): Mat4[GLfloat] =
  result = scene.camera.projection * scene.camera.view * translate(mat4(1.Glfloat), vec3(
                    transform.translation.x.GLfloat, transform.translation.y,
                    transform.translation.z))
