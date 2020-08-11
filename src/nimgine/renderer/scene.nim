import deques

import glm, opengl

import camera

import ../types
import ../ecs

proc newScene*(): Scene =
  let scene = Scene()
  scene.drawQueue = initDeque[Mesh]()
  result = scene

proc submit*(scene: Scene, mesh: Mesh) =
  scene.drawQueue.addLast(mesh)

proc preRender*(scene: Scene) =
  scene.camera.calcProjection()
  scene.camera.calcView()

proc setCamera*(scene: Scene, camera: Camera) =
  scene.camera = camera

proc setCameraDimensions*(scene: Scene, width, height: int) =
  scene.camera.width = width
  scene.camera.height = height

proc setCameraPosition*(scene: Scene, x, y, z: float) =
  scene.camera.position = vec3(x.GLfloat, y.GLfloat, z.GLfloat)

proc setCameraZoom*(scene: Scene, zoom: float) =
  scene.camera.zoom = zoom

proc setCameraOrientation*(scene: Scene, yaw, pitch, roll: float) =
  let front = vec3(
    cos(radians(yaw)).GLfloat * cos(radians(pitch)).GLfloat,
    sin(radians(pitch)),
    sin(radians(yaw)) * cos(radians(pitch))
  )
  scene.camera.front = normalize(front)
  scene.camera.right = normalize(cross(scene.camera.front, scene.camera.worldUp))
  scene.camera.up = normalize(cross(scene.camera.right, scene.camera.front))

proc calcMVPForMesh*(scene: Scene, mesh: Mesh): Mat4[GLfloat] =
  result = scene.camera.projection * scene.camera.view * mesh.model
