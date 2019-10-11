import ecs

type
    Position* = ref object of Component
        x*, y*: int
    Dimensions* = ref object of Component
        width*, height*: int
    Controllable* = ref object of Component
    RenderBlock* = ref object of Component
