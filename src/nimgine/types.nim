import tables, deques, sets, bitops
import glm, sdl2


const MAX_ENTITIES* = 32
const MAX_COMPONENTS* = 16

type
  EntityId* = uint32
  Component* = uint32
  
  Entity* = ref object
      id*: EntityId
      universe*: Universe 

  Signature* = BitsRange[MAX_COMPONENTS]

  AbstractComponentList* = ref object of RootObj

  ComponentList*[T] = ref object of AbstractComponentList
      data*: seq[T]
      entityIndexMap*: array[MAX_ENTITIES, int]
      indexEntityMap*: array[MAX_ENTITIES, EntityId]

  Universe* = ref object
      app*: Application
      entities*: Table[EntityId, Entity]
      entityIdPool*: Deque[EntityId]
      entityComponentIndex: seq[int]
      componentTypes*: Table[string, Component]
      components*: Table[Component, AbstractComponentList]
      entityComponents*: Table[EntityId, Signature]
      systems*: seq[System]

  Application* = ref object
    running*: bool
    world*: World
    universe*: Universe
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

    MouseLock

    RenderModeMesh
    RenderModeFull

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
      of MouseLock:
        lock*: bool
      of MouseMove, MousePosition:
        x*, y*: int
      of Resize:
        width*, height*: int
      else: discard

  EventQueue* = ref object
    queue*: Deque[Event]
    handlers*: Table[EventType, seq[proc(e: Event)]]

  System* = ref object
    id*: int
    events*: set[EventType]
    components*: HashSet[string]
    init*: proc(universe: Universe, system: System)
    handle*: proc(universe: Universe, system: System, event: Event, dt: float)
    update*: proc(universe: Universe, system: System, dt: float)
    preRender*: proc(universe: Universe, scene: Scene)
    render*: proc(universe: Universe, scene: Scene)
    syncToFrame*: bool

  Point* = float32

  World* = ref object
    entities*: seq[Entity]
    systems*: seq[System]
    up*: Vec3[Point]
    viewer*: Transform
    
  Camera* = object

  Controllable* = object

  Transform* = object
    translation*: Vec3[Point]
    rotation*: Vec3[Point]
    scale*: Vec3[Point]

  Terrain* = object
    size*: int
    density*: int
    octaves*: int
    amplitude*: float
    spreadX*: float
    spreadZ*: float
    persistence*: float

  Clock* = object
    ticks*, fps*: int
    dtUpdate*, dtRender*, lastUpdate*, lastRender*: float
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
    renderMode*: SceneRenderMode
    drawQueue*: Deque[(Model, Transform)]

  SceneRenderMode* {.pure.} = enum
    Mesh,
    Full

  SceneCamera* = ref object
    width*, height*: int
    position*, rotation*: Vec3[Point]
    front*: Vec3[Point]
    view*: Mat4[Point]
    projection*: Mat4[Point]

  Model* = object
    file*: string
    directory*: string
    initialized*: bool
    meshes*: seq[Mesh]

  Mesh* = ref object
    initialized*: bool
    shader*: Shader
    vao*: uint
    vbo*: uint
    ebo*: uint
    vertices*: seq[Vertex]
    indices*: seq[uint32]
    textures*: seq[Texture]
  
  
  UIWindow* = ref object
    id*: int
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
    UIEntityTree

  UIELement* = ref object
    id*: int
    window*: UIWindow
    case kind*: UIElementType
    of UIText:
      text*: string
    of UIButton:
      label*: string
      handler*: proc()
    of UIInput:
      buffer*: string
      onEnter*: proc(e: UIElement)
    of UISlider:
      min*, max*: float32
      name*: string
      value*: ptr float32
    of UIRow:
      children*: seq[UIELement]
    of UIConsole:
      history*: int
      lines*: Deque[string]
      scrollToBottom*: bool
    of UIEntityTree:
      entities*: seq[Entity]
