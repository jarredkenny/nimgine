import ../types
import ../ecs
import ../ui

var guiSystem* = newSystem()

guiSystem.subscribe(@[Resize, MouseMove])

guiSystem.handle = proc(world: World, system: System, event: Event) =
  case event.kind:
    of Resize:
      ui.setDisplaySize(event.width, event.height)
    of MouseMove:
      ui.setMousePosition(event.x, event.y)
    else: discard
