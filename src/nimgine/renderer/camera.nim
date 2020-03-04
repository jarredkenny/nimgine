import glm
import opengl
import sdl2

import ../types

# proc newCamera*(): Camera =
#     Camera(
#         yaw: -90.0,
#         pitch: 0.0,
#         speed: 6.0,
#         sensitivity: 0.25,
#         zoom: 45.0
#         position: Vec3(0.0, 0.0, 0.0),
#         normal: Vec3(0.0, 1.0, 0.1)
#     )

# https://github.com/tomdalling/opengl-series/blob/master/source/04_camera/source/tdogl/Camera.cpp


proc orientation*(): Mat4[GLfloat] =
    result = rotate(result, radians(0.0).GLfloat, vec3(1.0.GLfloat, 0.0.GLfloat, 0.0.GLfloat))
    result = rotate(result, radians(0.0).GLfloat, vec3(0.GLfloat, 1.GLfloat, 0.GLfloat))

proc newCamera*(width, height: float): Camera =
    var proj, model, view: Mat4[GLfloat]

    proj = perspective(radians(45.0).GLfloat, (width / height).GLfloat,
        0.1.GLfloat, 100.0.GLfloat)

    view = orientation() * translate()


    model = rotate(model, (1 * 1.0).GLfloat, vec3(0.0.GLfloat, (getTicks(
            ).float *
        1.0).GLfloat, 0.0.GLfloat))

    result = Camera(view: view, projection: proj, model: model)
