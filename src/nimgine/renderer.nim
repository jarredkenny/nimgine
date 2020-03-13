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

  var view: Mat4[GLfloat] = lookAt(camera.position, vec3(0.GLfloat, 0.GLfloat,
      0.GLfloat), vec3(0.GLfloat, 1.GLfloat, 0.GLfloat))

  var mvp = camera.projection * view * model

  for mesh in app.scene.drawQueue.items:
    app.scene.drawQueue.popFirst()
    mesh.use()
    mesh.uniform("MVP", mvp)
    mesh.draw()



  # var count: int = 0;
  # for mesh in app.scene.drawQueue.items:
  #   app.scene.drawQueue.popFirst()
  #   var camera = app.scene.camera.

  #   let rotation: GLfloat = radians(getTicks().float * 0.05).GLFloat
  #   let rotationDir: Vec3[GLfloat] = vec3(0.GLfloat, 1.GLfloat, 0.GLfloat)

  #   var model: Mat4[GlFloat] = rotate(mat4(1.GLfloat), rotation, rotationDir)

  #   model = translate(model, 0.GLfloat, sin(getTicks().float * 0.001 *
  #       (count.float + 1.0)).GLfloat, (count * 4).GLfloat)

  #   model = rotate(model, -rotation, rotationDir)

  #   let camR = radians(getTicks().float * 0.01).GLfloat

  #   var view = rotate(camera.view, camR, vec3(0.GLfloat, 1.GLfloat, 1.GLfloat))



  #   inc(count)

  #   var mvp = camera.projection * view * model

  #   mesh.use()
  #   mesh.uniform("MVP", mvp)
  #   mesh.draw()

var RendererLayer* = ApplicationLayer()

RendererLayer.render = render
