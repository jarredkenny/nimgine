import math, deques, strformat
import opengl
import glm
import sdl2

import types

import renderer/[mesh, shader, scene, camera, terrain]

export newMesh
export newModel
export newShader
export init
export newScene
export newSceneCamera
export submit
export setCameraPosition
export setCameraDimensions
export loadTexture
export newTerrainModel
export loadTextureWithMips

proc handle(app: Application, event: types.Event) =
  case event.kind:
    of RenderModeMesh: app.scene.renderMode = SceneRenderMode.Mesh
    of RenderModeFull: app.scene.renderMode = SceneRenderMode.Full
    else: discard

proc preRender(app: Application) =
  app.scene.preRender()
  drawCalls = 0

proc render*(app: Application) =
  for (model, transform) in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    var mvp = app.scene.calcMVPForMesh(model, transform)

    model.draw(mvp, app.scene.renderMode)

var RendererLayer* = ApplicationLayer(preRender: preRender, handle: handle, render: render)
