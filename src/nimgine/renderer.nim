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
export newSceneCamera
export newScene
export submit
export setCameraPosition
export setCameraDimensions
export setCameraTargetPosition

proc preRender(app: Application) =
  app.scene.preRender()

proc render*(app: Application) =

  for mesh in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    var mvp = app.scene.calcMVPForMesh(mesh)

    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()

var RendererLayer* = ApplicationLayer(preRender: preRender, render: render)