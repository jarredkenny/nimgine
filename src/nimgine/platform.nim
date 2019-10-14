import sdl2
import opengl

import input
import events

var screenWidth: cint = 640
var screenHeight: cint = 480
var window: WindowPtr
var context: GlContextPtr
var event = defaultEvent

proc toInput(key: Scancode): InputType =
  case key
  of SDL_SCANCODE_A: input.Left
  of SDL_SCANCODE_D: input.Right
  of SDL_SCANCODE_SPACE: input.Jump
  of SDL_SCANCODE_W: input.Up
  of SDL_SCANCODE_S: input.Down
  of SDL_SCANCODE_E: input.ZoomIn
  of SDL_SCANCODE_Q: input.ZoomOut
  of SDL_SCANCODE_ESCAPE: input.Pause
  else: input.None

proc init*() =
  # Init SDL
  discard sdl2.init(INIT_EVERYTHING)

  # Configure OpenGL Version
  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4)
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 4)
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  discard glSetAttribute(SDL_GL_DEPTH_SIZE, 24)

  # Create Window
  window = createWindow(
    "Nimgine",
    1, 1,
    screenWidth, screenHeight,
    SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE
    )

  # Create opengl context
  context = window.glCreateContext()

  # Init opengl
  loadExtensions()
  glClearColor(0.0, 0.5, 0.5, 1.0)
  glViewport(0, 0, screenWidth, screenHeight)

proc reshape(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)

proc update*() =
  # Handle SDL event
  while pollEvent(event):
    # Handle Quit Event
    if event.kind == sdl2.EventType.QuitEvent:
      queueEvent(events.Quit)

    if event.kind == sdl2.EventType.KeyDown:
      queueEvent(newInputEvent(event.key.keysym.scancode.toInput, true))

    if event.kind == sdl2.EventType.KeyUp:
      queueEvent(newInputEvent(event.key.keysym.scancode.toInput, false))

    if event.kind == sdl2.EventType.MouseMotion:
      queueEvent(newMouseMoveEvent(event.motion.x, event.motion.y))

    # Handle Window Events
    if event.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(event))

      # Handle Window Resize
      if windowEvent.event == WindowEvent_Resized:
        reshape(windowEvent.data1, windowEvent.data2)
        queueEvent(events.Resize)

proc preRender*() =
  glClear(GL_COLOR_BUFFER_BIT)

proc render*() =
  window.glSwapWindow()
