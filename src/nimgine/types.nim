import tables, deques, sets
import glm, sdl2

type

  Application* = ref object
    running*: bool
    world*: World
    scene*: Scene
    clock*: Clock
    bus*: EventQueue
    logger*: Logger
    window*: WindowPtr
    windows*: seq[UIWindow]
    layers*: seq[ApplicationLayer]

  ApplicationLayer* = ref object of RootObj
    init*: proc(app: Application)
    poll*: proc(app: Application)
    handle*: proc(app: Application, event: Event)
    update*: proc(app: Application)
    preRender*: proc(app: Application)
    render*: proc(app: Application)
    destroy*: proc(app: Application)
    syncToFrame*: bool

  Logger* = ref object
    level*: LogLevel
    queue*: Deque[string]

  LogLevel*{.pure.} = enum
    Debug,
    Info,
    Warn,
    Error

  EventType*{.pure.} = enum

    # Input Type Events
    Charecter
    Input

    MouseMove
    # Platform State Events
    Quit
    Resize

    # Control Intents
    MoveForward
    MoveBackward
    MoveLeft
    MoveRight
    PanUp
    PanDown
    PanRight
    PanLeft

    # UI Events
    MousePosition

    # System Events
    Log

    LockKeyboardInput
    UnlockKeyboardInput

  Event* = ref object
    handled*: bool
    case kind*: EventType
      of Log:
        line*: string
      of Input:
        input*: InputType
        state*: bool
        unicode*: uint32
      of Charecter:
        charecter*: char
      of MouseMove, MousePosition:
        x*, y*: int
      of Resize:
        width*, height*: int
      else: discard

  EventQueue* = ref object
    queue*: Deque[Event]
    handlers*: Table[EventType, seq[proc(e: Event)]]

  Component* = ref object of RootObj
    id*: int

  Entity* = ref object
    id*: int
    components*: Table[string, Component]

  System* = ref object
    id*: int
    events*: set[EventType]
    components*: HashSet[string]
    init*: proc(world: World, system: System)
    handle*: proc(app: Application, system: System, event: Event, dt: float)
    update*: proc(app: Application, system: System, dt: float)
    preRender*: proc(scene: Scene, world: World)
    render*: proc(scene: Scene, world: World)
    syncToFrame*: bool

  Point* = float32

  World* = ref object
    entities*: seq[Entity]
    systems*: seq[System]
    up*: Vec3[Point]

  Camera* = ref object of Component

  Controllable* = ref object of Component

  Transform* = ref object of Component
    translation*: Vec3[Point]
    rotation*: Vec3[Point]
    scale*: Vec3[Point]

  Clock* = object
    ticks*, fps*: int
    dtUpdate*, dtRender*, lastRender*: float
    isFirstInFrame*: bool

  InputState* = bool

  InputType*{.pure.} = enum

    Key1
    Key2
    Key3
    Key4
    Key5
    Key6
    Key7
    Key8
    Key9

    KeyA
    KeyB
    KeyC
    KeyD
    KeyE
    KeyF
    KeyG
    KeyH
    KeyI
    KeyJ
    KeyK
    KeyL
    KeyM
    KeyN
    KeyO
    KeyP
    KeyQ
    KeyR
    KeyS
    KeyT
    KeyU
    KeyV
    KeyW
    KeyX
    KeyY
    KeyZ

    KeyTab
    KeyEnter
    KeyKPEnter
    KeyDelete
    KeyInsert
    KeyEnd
    KeyHome
    KeyPageUp
    KeyPageDown
    KeySpace
    KeyEscape
    KeySlash
    KeyBackspace

    KeyArrowUp
    KeyArrowDown
    KeyArrowLeft
    KeyArrowRight

    MouseLeft
    MouseRight
    MouseScrollUp
    MouseScrollDown

    Char

    None

  Shader* = ref object
    id*: uint

  # New Mesh Types
  Vertex* = object
    position*: Vec3[Point]
    normal*: Vec3[Point]
    texCoord*: Vec2[Point]

  Index* = uint

  TextureType* {.pure.} = enum
    TextureDiffuse,
    TextureSpecular,
    TextureNormal,
    TextureHeight

  Texture* = ref object
    id*: uint
    kind*: TextureType
    path*: string
    
  Scene* = ref object
    camera*: SceneCamera
    drawQueue*: Deque[(Model, Transform)]

  SceneCamera* = ref object
    width*, height*: int
    position*: Vec3[Point]
    front*: Vec3[Point]
    view*: Mat4[Point]
    projection*: Mat4[Point]

  Model* = ref object of Component
    file*: string
    directory*: string
    initialized*: bool
    meshes*: seq[Mesh]

  Mesh* = ref object
    shader*: Shader
    vao*: uint
    vbo*: uint
    ebo*: uint
    vertices*: seq[Vertex]
    indices*: seq[uint32]
    textures*: seq[Texture]
  
  
  UIWindow* = ref object
    name*: string
    open*: bool
    elements*: seq[UIElement]

  UIElementType* = enum
    UIButton
    UIText
    UISlider
    UIInput
    UIRow
    UIConsole

  UIELement* = ref object
    case kind*: UIElementType
    of UIText:
      text*: string
    of UIButton:
      label*: string
      handler*: proc()
    of UIInput:
      buffer*: string
      onEnter*: proc(e: UIElement)
    of UIRow:
      children*: seq[UIELement]
    of UIConsole:
      history*: int
      lines*: Deque[string]
      scrollToBottom*: bool
    else: discard
