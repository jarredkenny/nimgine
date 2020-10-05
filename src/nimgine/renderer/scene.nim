import deques

import glm, opengl

import camera

import ../types

proc newScene*(): Scene =
  let scene = Scene()
  scene.camera = newSceneCamera(0, 0)
  scene.drawQueue = initDeque[Mesh]()
  result = scene

proc submit*(scene: Scene, mesh: Mesh) =
  scene.drawQueue.addLast(mesh)

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

proc calcMVPForMesh*(scene: Scene, mesh: Mesh): Mat4[GLfloat] =
  result = scene.camera.projection * scene.camera.view * mesh.model
