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
  var camera = app.scene.camera

  var model: Mat4[GLfloat] = mat4(1.GLfloat)

  var mvp = camera.projection * camera.view * model

  for mesh in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()

var RendererLayer* = ApplicationLayer()

RendererLayer.render = render

# discard loadModel("/home/jarred/Code/nimgine/models/HUMAN.blend")
