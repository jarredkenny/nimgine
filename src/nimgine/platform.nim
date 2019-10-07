import sugar

import opengl/glut
import opengl
import opengl/glu

include clock

var clock: Clock = newClock()

type UpdateFunc = proc(dt: float): void
var gameLoopFunc: UpdateFunc = (dt: float) => void

proc reshape(width: GLsizei, height: GLsizei) {.cdecl.} =
    if height == 0:
        return
    echo "Resized: " & $width & "x" & $height
    glViewport(0, 0, width, height)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, width / height, 0.1, 100.0)

proc display() {.cdecl.} =
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    glTranslatef(1.5, 0.0, -7.0)
    glBegin(GL_TRIANGLES)
    glEnd()
    glutSwapBuffers()

proc loop() {.cdecl.} =
    update(clock)
    if gameLoopFunc != nil:
        echo("Calling loop")
        gameLoopFunc(clock.dt)

proc setGameLoopFunc*(loopFunc: UpdateFunc):
    gameLoopFunc = loopFunc

proc init*() =
    # Glut Setup
    var argc: cint = 0
    glutInit(addr argc, nil)
    glutInitDisplayMode(GLUT_DOUBLE)
    glutInitWindowSize(640, 480)
    glutInitWindowPosition(50, 50)

    # Create Window
    discard glutCreateWindow("Nimgine")

    # Setup callbacks
    glutDisplayFunc(display)
    glutReshapeFunc(reshape)
    glutIdleFunc(loop)

    # Load Extensions
    loadExtensions()

    # Init GL State
    glClearColor(0.0, 0.0, 0.0, 1.0) # Black
    glClearDepth(1.0)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glShadeModel(GL_SMOOTH)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

    # Enter GLUT main loop
    glutMainLoop()
