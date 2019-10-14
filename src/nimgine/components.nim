import ecs

type
    Position* = ref object of Component
        x*, y*: float
    Dimensions* = ref object of Component
        width*, height*: float
    Controllable* = ref object of Component
    RenderBlock* = ref object of Component
