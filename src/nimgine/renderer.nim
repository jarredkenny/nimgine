import math, deques, strformat
import opengl
import glm
import sdl2

import types

import renderer/[mesh, shader, scene, camera]

export newModel
export newShader
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
  for (model, transform) in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    var mvp = app.scene.calcMVPForMesh(model, transform)

    model.draw(mvp)

var RendererLayer* = ApplicationLayer(preRender: preRender, render: render)
