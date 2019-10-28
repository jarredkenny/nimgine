import sdl2
import opengl

import types
import events

var screenWidth: cint = 640
var screenHeight: cint = 480
var context: GlContextPtr
var event = defaultEvent
var keyboardCharInput = false

proc toInput(key: Scancode): InputType =
  case key
  of SDL_SCANCODE_A: InputType.KeyA
  of SDL_SCANCODE_B: InputType.KeyB
  of SDL_SCANCODE_C: InputType.KeyC
  of SDL_SCANCODE_D: InputType.KeyD
  of SDL_SCANCODE_E: InputType.KeyE
  of SDL_SCANCODE_F: InputType.KeyF
  of SDL_SCANCODE_G: InputType.KeyG
  of SDL_SCANCODE_H: InputType.KeyH
  of SDL_SCANCODE_I: InputType.KeyI
  of SDL_SCANCODE_J: InputType.KeyJ
  of SDL_SCANCODE_K: InputType.KeyK
  of SDL_SCANCODE_L: InputType.KeyL
  of SDL_SCANCODE_M: InputType.KeyM
  of SDL_SCANCODE_N: InputType.KeyN
  of SDL_SCANCODE_O: InputType.KeyO
  of SDL_SCANCODE_P: InputType.KeyP
  of SDL_SCANCODE_Q: InputType.KeyQ
  of SDL_SCANCODE_R: InputType.KeyR
  of SDL_SCANCODE_S: InputType.KeyS
  of SDL_SCANCODE_T: InputType.KeyT
  of SDL_SCANCODE_U: InputType.KeyU
  of SDL_SCANCODE_V: InputType.KeyV
  of SDL_SCANCODE_W: InputType.KeyW
  of SDL_SCANCODE_X: InputType.KeyX
  of SDL_SCANCODE_Y: InputType.KeyY
  of SDL_SCANCODE_Z: InputType.KeyZ
  of SDL_SCANCODE_SPACE: InputType.KeySpace
  of SDL_SCANCODE_ESCAPE: InputType.KeyEscape
  else: InputType.None

proc init*(app: Application) =

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

proc poll(app: Application) =

  # Handle SDL event
  while pollEvent(event):

    # Handle Quit Event
    if event.kind == sdl2.EventType.QuitEvent:
      queueEvent(types.EventType.Quit)

    if not keyboardCharInput:

      if event.kind == sdl2.EventType.KeyDown:
        queueEvent(newInputEvent(event.key.keysym.scancode.toInput, true))

      if event.kind == sdl2.EventType.KeyUp:
        queueEvent(newInputEvent(event.key.keysym.scancode.toInput, false))

    else:
      if event.kind == sdl2.EventType.TextInput:
        var a = cast[TextInputEventPtr](event.text)
        queueEvent(newCharEvent(a.text[0]))

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

    # Mouse Wheel Scrolling
    if event.kind == MouseWheel:
      var mouseWheelEvent = cast[MouseWheelEventPtr](event.addr)
      case mouseWheelEvent.y:
        of -1: queueEvent(newInputEvent(MouseScrollDown))
        of 1: queueEvent(newInputEvent(MouseScrollUp))
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

proc handle(app: Application, event: types.Event) =
  case event.kind:
    of types.EventType.MousePosition:
      warpMouseInWindow(app.window, event.x.cint, event.y.cint)
    of types.EventType.LockKeyboardInput:
      keyboardCharInput = true
      startTextInput()
    of types.EventType.UnlockKeyboardInput:
      keyboardCharInput = false
      stopTextInput()
    else: discard

proc preRender*(app: Application) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc render*(app: Application) =
  app.window.glSwapWindow()
  if getTicks().float < 1000 / 60:
    delay((1000 / 60 - getTicks().float).uint32)


var PlatformLayer* = ApplicationLayer()

PlatformLayer.init = init
PlatformLayer.poll = poll
PlatformLayer.handle = handle
PlatformLayer.preRender = preRender
PlatformLayer.render = render
