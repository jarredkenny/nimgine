import tables, deques, sets
import glm, opengl, sdl2

type
  Application* = ref object
    running*: bool
    world*: World
    scene*: Scene
    clock*: Clock
    window*: WindowPtr
    windows*: seq[UIWindow]
    layers*: seq[ApplicationLayer]

  ApplicationLayer* = ref object of RootObj
    init*: proc(app: Application)
    update*: proc(app: Application)
    handle*: proc(app: Application, event: Event)
    preRender*: proc(app: Application)
    render*: proc(app: Application)
    destroy*: proc(app: Application)

  EventType*{.pure.} = enum

    # Input Type Evens
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

  Event* = ref object
    handled*: bool
    case kind*: EventType
      of Input:
        input*: InputType
        state*: bool
      of MouseMove, MousePosition:
        x*, y*: int
      of Resize:
        width*, height*: int
      else: discard2

  EventQueue* = Deque[Event]

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
    handle*: proc(world: World, system: System, event: Event)
    update*: proc(world: World, system: System, dt: float)
    preRender*: proc(scene: Scene, world: World)
    render*: proc(scene: Scene, world: World)

  World* = ref object
    entities*: seq[Entity]
    systems*: seq[System]

  Position* = ref object of Component
    x*, y*, z*: float
  Dimensions* = ref object of Component
    width*, height*, depth*: float

  ControlledCamera* = ref object of Component
  Controllable* = ref object of Component
  RenderBlock* = ref object of Component

  Clock* = object
    dt*: float
    fps*: float
    timer*: float
    ticks*: int
    last*: float

  InputState* = bool

  InputType*{.pure.} = enum

    # Key Controls
    Up
    Down
    Left
    Right
    Jump
    Pause
    ZoomIn
    ZoomOut
    Quit

    MouseLeft
    MouseRight
    MouseScrollUp
    MouseScrollDown

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

  Mesh* = ref object
    vao*: uint
    buffers*: seq[VertexBuffer]
    elements*: IndexBuffer
    shader*: Shader

  Camera* = ref object
    projection*: Mat4[GLfloat]
    view*: Mat4[GLfloat]

  Scene* = ref object
    camera*: Camera
    drawQueue*: Deque[Mesh]

  UIWindow* = ref object
    name*: string
    open*: bool
    elements*: seq[UIElement]

  UIELement* = ref object
    case kind*: UIElementType
    of UIButton

  UIElementType* = enum
    UIButton
    UIText
