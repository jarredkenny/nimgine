import glm
import opengl

import ../types

proc orientation*(): Mat4[GLfloat] =
    result = rotate(result, radians(0.0).GLfloat, vec3(1.0.GLfloat, 0.0.GLfloat, 0.0.GLfloat))
    result = rotate(result, radians(0.0).GLfloat, vec3(0.GLfloat, 1.GLfloat, 0.GLfloat))

proc newSceneCamera*(width, height: int): SceneCamera =
    result = SceneCamera(width: width, height: height)


proc calcProjection*(camera: var SceneCamera) =
    camera.projection = perspective(radians(45.0).GLfloat, (camera.width /
            camera.height).GLfloat, 0.1.GLfloat, 100.0.GLfloat)

proc calcView*(camera: var SceneCamera) =
    camera.view = lookAt(
        camera.position,
        camera.position + camera.target,
        vec3(0.GLfloat, 1, 0)
    )
