import tables, deques, sets
import glm, opengl, sdl2

type
  Application* = ref object
    running*: bool
    world*: World
    scene*: Scene
    clock*: Clock
    bus*: EventQueue
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

  EventType*{.pure.} = enum

    # Input Type Events
    Charecter
    Input
    MouseMove

    # Platform State Events
    Quit
    Resize

    # Control Intents
    MoveUp
    MoveDown
    MoveLeft
    MoveRight
    ZoomIn
    ZoomOut

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

  World* = ref object
    entities*: seq[Entity]
    systems*: seq[System]

  Position* = ref object of Component
    x*, y*, z*: float

  ControlledCamera* = ref object of Component
  Controllable* = ref object of Component

  Clock* = object
    dt*: float
    fps*: float
    timer*: float
    ticks*: int
    last*: float

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

  VertexBuffer* = ref object
    id*: uint
    vertices*: seq[float]
    name*: string
    layout*: AttributeLayout

  IndexBuffer* = ref object
    id*: uint
    indices*: seq[int]

  AttributeLayout* = ref object
    size*, stride*, offset*: int

  Shader* = ref object
    id*: uint
    attributes*: Table[string, AttributeLayout]

  # New Mesh Types
  Vertex* = object
    position*: Vec3[float32]
    normal*: Vec3[float32]
    texCoord*: Vec2[float32]

  Index* = uint

  Texture* = ref object
    id*: uint
    kind*: string # TODO: use an enum for texture type?
    path8: string

  Mesh* = ref object of Component
    initialized*: bool
    file*: string
    model*: Mat4[GLfloat]
    shader*: Shader
    vao*: uint
    vbo*: uint
    ebo*: uint
    vertices*: seq[Vertex]
    indices*: seq[GLuint]
    textures*: seq[Texture]

  Camera* = ref object
    pitch*: GLfloat
    angle*: GLfloat
    zoom*: GLfloat
    position*: Vec3[GLfloat]
    projection*: Mat4[GLfloat]
    view*: Mat4[GLfloat]

  Scene* = ref object
    camera*: Camera
    drawQueue*: Deque[Mesh]

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
      handleEnter*: proc()
    of UIRow:
      children*: seq[UIELement]
    of UIConsole:
      history*: int
      lines*: Deque[string]
    else: discard
