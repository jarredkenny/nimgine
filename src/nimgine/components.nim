import ecs

type
    Position* = ref object of Component
        x*, y*, z*: float
    Dimensions* = ref object of Component
        width*, height*, depth*: float

    ControlledCamera* = ref object of Component
    Controllable* = ref object of Component
    RenderBlock* = ref object of Component
