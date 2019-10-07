import sdl2
import opengl
import opengl/glu

import events

var screenWidth: cint = 640
var screenHeight: cint = 480
var window: WindowPtr
var context: GlContextPtr
var event = defaultEvent

proc init*() =
    # Create Window
    window = createWindow(
        "Nimgine",
        100, 100,
        screenWidth, screenHeight,
        SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE
    )

    # Create opengl context
    context = window.glCreateContext()

    # Init opengl
    loadExtensions()
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glClearDepth(1.0)
    glEnable(Gl_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glShadeModel(Gl_SMOOTH)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

proc reshape(newWidth: cint, newHeight: cint) =
    echo("Reshape: " & $newWidth & "x" & $newHeight)
    glViewport(0, 0, newWidth, newHeight)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, newWidth / newHeight, 0.1, 100.0)

proc update*() =
    while pollEvent(event):
        if event.kind == QuitEvent:
            queueEvent(events.Event.Quit)
        if event.kind == WindowEvent:
            var windowEvent = cast[WindowEventPtr](addr(event))
            if windowEvent.event == WindowEvent_Resized:
                reshape(windowEvent.data1, windowEvent.data2)
                queueEvent(events.Event.Resize)

proc render*() =
    window.glSwapWindow()
