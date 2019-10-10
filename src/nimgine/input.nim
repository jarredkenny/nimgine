import tables

type
  InputState* = bool

  InputType* = enum
    Up
    Down
    Left
    Right
    Jump
    Pause
    None

  InputManager* = ref object
    inputs*: Table[InputType, InputState]

proc newInputManager*(): InputManager =
  result = InputManager()
