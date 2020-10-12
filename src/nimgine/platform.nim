import sdl2
import opengl

import types
import events

var screenWidth: cint = 1920
var screenHeight: cint = 1080
var context: GlContextPtr
var event = defaultEvent
var keyboardCharInput = false

proc toInput(key: Scancode): InputType =
  case key
  of SDL_SCANCODE_A: KeyA
  of SDL_SCANCODE_B: KeyB
  of SDL_SCANCODE_C: KeyC
  of SDL_SCANCODE_D: KeyD
  of SDL_SCANCODE_E: KeyE
  of SDL_SCANCODE_F: KeyF
  of SDL_SCANCODE_G: KeyG
  of SDL_SCANCODE_H: KeyH
  of SDL_SCANCODE_I: KeyI
  of SDL_SCANCODE_J: KeyJ
  of SDL_SCANCODE_K: KeyK
  of SDL_SCANCODE_L: KeyL
  of SDL_SCANCODE_M: KeyM
  of SDL_SCANCODE_N: KeyN
  of SDL_SCANCODE_O: KeyO
  of SDL_SCANCODE_P: KeyP
  of SDL_SCANCODE_Q: KeyQ
  of SDL_SCANCODE_R: KeyR
  of SDL_SCANCODE_S: KeyS
  of SDL_SCANCODE_T: KeyT
  of SDL_SCANCODE_U: KeyU
  of SDL_SCANCODE_V: KeyV
  of SDL_SCANCODE_W: KeyW
  of SDL_SCANCODE_X: KeyX
  of SDL_SCANCODE_Y: KeyY
  of SDL_SCANCODE_Z: KeyZ
  of SDL_SCANCODE_SPACE: KeySpace
  of SDL_SCANCODE_ESCAPE: KeyEscape
  of SDL_SCANCODE_BACKSPACE: KeyBackspace
  of SDL_SCANCODE_KP_ENTER: KeyKPEnter
  of SDL_SCANCODE_RETURN: KeyEnter
  of SDL_SCANCODE_LEFT: KeyArrowLeft
  of SDL_SCANCODE_RIGHT: KeyArrowRight
  of SDL_SCANCODE_UP: KeyArrowUp
  of SDL_SCANCODE_DOWN: KeyArrowDown
  of SDL_SCANCODE_DELETE: KeyDelete
  of SDL_SCANCODE_INSERT: KeyInsert
  of SDL_SCANCODE_END: KeyEnd
  of SDL_SCANCODE_HOME: KeyHome
  of SDL_SCANCODE_PAGEUP: KeyPageUp
  of SDL_SCANCODE_PAGEDOWN: KeyPageDown
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
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

proc reshape(newWidth: cint, newHeight: cint) =
  glViewport(0, 0, newWidth, newHeight)

proc poll(app: Application) =

  # Handle SDL event
  while pollEvent(event):

    # Handle Quit Event
    if event.kind == sdl2.EventType.QuitEvent:
      app.bus.queueEvent(types.EventType.Quit)

    if not keyboardCharInput:
      if event.kind == sdl2.EventType.KeyDown:
        app.bus.queueEvent(newInputEvent(event.key.keysym.scancode.toInput, true))

      if event.kind == sdl2.EventType.KeyUp:
        app.bus.queueEvent(newInputEvent(event.key.keysym.scancode.toInput, false))

    elif event.kind == sdl2.EventType.TextInput:
      var a = cast[TextInputEventPtr](event.text)
      app.bus.queueEvent(newCharEvent(a.text[0]))

    if event.kind == sdl2.EventType.MouseMotion:
      app.bus.queueEvent(newMouseMoveEvent(event.motion.x, event.motion.y))

    # Mouse Buttons
    if event.kind == MouseButtonDown or event.kind == MouseButtonUp:
      var mouseButtonEvent = cast[MouseButtonEventPtr](event.addr)
      var state = cast[bool](mouseButtonEvent.state)
      case mouseButtonEvent.button:
        of 1: app.bus.queueEvent(newInputEvent(MouseLeft, state))
        of 3: app.bus.queueEvent(newInputEvent(MouseRight, state))
        else: discard

    # Mouse Wheel Scrolling
    if event.kind == MouseWheel:
      var mouseWheelEvent = cast[MouseWheelEventPtr](event.addr)
      case mouseWheelEvent.y:
        of -1: app.bus.queueEvent(newInputEvent(MouseScrollDown))
        of 1: app.bus.queueEvent(newInputEvent(MouseScrollUp))
        else: discard

    # Handle Window Events
    if event.kind == WindowEvent:
      var windowEvent = cast[WindowEventPtr](addr(event))

      # Handle Window Resize
      if windowEvent.event == WindowEvent_Resized:
        let width = windowEvent.data1
        let height = windowEvent.data2
        reshape(width, height)
        screenHeight = height
        screenWidth = width
        app.bus.queueEvent(newResizeEvent(width, height))

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


var PlatformLayer* = ApplicationLayer(
  init: init,
  poll: poll,
  handle: handle,
  preRender: preRender,
  render: render,
  syncToFrame: true,
)
