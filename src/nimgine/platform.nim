import sdl2
import opengl

import types
import events

var screenWidth: cint = 640
var screenHeight: cint = 480
var context: GlContextPtr
var event = defaultEvent

proc toInput(key: Scancode): InputType =
  case key
  of SDL_SCANCODE_A: InputType.Left
  of SDL_SCANCODE_D: InputType.Right
  of SDL_SCANCODE_SPACE: InputType.Jump
  of SDL_SCANCODE_W: InputType.Up
  of SDL_SCANCODE_S: InputType.Down
  # of SDL_SCANCODE_E: InputType.ZoomIn
  # of SDL_SCANCODE_Q: InputType.ZoomOut
  # of SDL_SCANCODE_ESCAPE: InputType.Quit
  else: InputType.None

proc init*(app: Application) =
  echo("PLATFORM INIT")

  # Init SDL
  discard sdl2.init(INIT_EVERYTHING)

  # Configure OpenGL Version
  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4)
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 4)
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)
  discard glSetAttribute(SDL_GL_DEPTH_SIZE, 24)

  # Create Window
  app.window = createWindow(
    "Nimgine",
    1, 1,
    screenWidth, screenHeight,
    SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE
    )

  # Create opengl context
  context = app.window.glCreateContext()

  # Init opengl
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glEnable(GL_DEPTH_TEST)
  glDepthFunc(GL_LEQUAL)
  glViewport(0, 0, screenWidth, screenHeight)

proc reshape(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)

proc update*(app: Application) =
  echo("PLATFORM UPDATE")
  # Handle SDL event
  while pollEvent(event):

    # Handle Quit Event
    if event.kind == sdl2.EventType.QuitEvent:
      queueEvent(types.EventType.Quit)

    if event.kind == sdl2.EventType.KeyDown:
      queueEvent(newInputEvent(event.key.keysym.scancode.toInput, true))

    if event.kind == sdl2.EventType.KeyUp:
      queueEvent(newInputEvent(event.key.keysym.scancode.toInput, false))

    if event.kind == sdl2.EventType.MouseMotion:
      queueEvent(newMouseMoveEvent(event.motion.x, event.motion.y))

    # Mouse Buttons
    if event.kind == MouseButtonDown or event.kind == MouseButtonUp:
      var mouseButtonEvent = cast[MouseButtonEventPtr](event.addr)
      var state = cast[bool](mouseButtonEvent.state)
      case mouseButtonEvent.button:
        of 1: queueEvent(newInputEvent(MouseLeft, state))
        of 3: queueEvent(newInputEvent(MouseRight, state))
        else: discard

    # Handle Window Events
    if event.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(event))

      # Handle Window Resize
      if windowEvent.event == WindowEvent_Resized:
        let width = windowEvent.data1
        let height = windowEvent.data2
        reshape(width, height)
        queueEvent(newResizeEvent(width, height))

proc preRender*(app: Application) =
  echo("PLATFORM PRE-RENDER: CLEAR")
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc render*(app: Application) =
  echo("PLATFORM RENDER")
  app.window.glSwapWindow()


var PlatformLayer* = ApplicationLayer()

PlatformLayer.init = init
PlatformLayer.update = update
PlatformLayer.preRender = preRender
PlatformLayer.render = render
