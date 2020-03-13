import glm
import opengl

import ../types

proc orientation*(): Mat4[GLfloat] =
    result = rotate(result, radians(0.0).GLfloat, vec3(1.0.GLfloat, 0.0.GLfloat, 0.0.GLfloat))
    result = rotate(result, radians(0.0).GLfloat, vec3(0.GLfloat, 1.GLfloat, 0.GLfloat))

proc newCamera*(width, height: float): Camera =
    var proj: Mat4[GLfloat] = perspective(radians(45.0).GLfloat, (width /
            height).GLfloat, 0.1.GLfloat, 100.0.GLfloat)
    result = Camera(projection: proj)
