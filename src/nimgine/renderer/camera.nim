import glm
import opengl

import ../types

proc newSceneCamera*(width, height: int): SceneCamera =
    result = SceneCamera(width: width, height: height)

proc calcProjection*(camera: var SceneCamera) =
    camera.projection = perspective(radians(45.0).GLfloat, (camera.width /
            camera.height).GLfloat, 0.1.GLfloat, 1000.0.GLfloat)

proc calcView*(camera: var SceneCamera) =
    camera.view = lookAt(
        camera.position,
        camera.position + camera.front,
        vec3(0.GLfloat, 1, 0)
    )