import math, deques
import opengl
import glm
import sdl2

import types

import renderer/[buffers, mesh, shader, scene, camera]

export newShader
export newVertexBuffer
export newIndexBuffer
export newMesh
export newCamera
export newScene
export submit
export setCameraPosition

proc render*(app: Application) =
  for mesh in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    var camera = app.scene.camera
    var mvp = camera.projection * camera.view * camera.model
    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()

var RendererLayer* = ApplicationLayer()

RendererLayer.render = render
