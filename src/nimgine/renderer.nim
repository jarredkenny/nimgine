import math, deques, strformat
import opengl
import glm
import sdl2

import types

import renderer/[buffers, mesh, shader, scene, camera]

export newShader
export newVertexBuffer
export newIndexBuffer
export init
export newScene
export newSceneCamera
export submit
export setCameraPosition
export setCameraDimensions

proc preRender(app: Application) =
  app.scene.preRender()
  drawCalls = 0

proc render*(app: Application) =

  for (mesh, transform) in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    var mvp = app.scene.calcMVPForMesh(mesh, transform)

    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()

var RendererLayer* = ApplicationLayer(preRender: preRender, render: render)
