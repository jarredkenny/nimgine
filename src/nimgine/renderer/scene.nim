import deques

from camera import newCamera

import ../types

proc newScene*(): Scene =
  let scene = Scene()
  scene.camera = newCamera(0.0, 0.0)
  scene.drawQueue = initDeque[Mesh]()
  result = scene

proc submit*(scene: Scene, mesh: Mesh) =
  scene.drawQueue.addLast(mesh)

proc preRender*(scene: Scene) =
  discard

proc setCameraPosition*(scene: Scene, width, height: float) =
  echo "setCameraPosition"
  scene.camera = newCamera(width, height)
