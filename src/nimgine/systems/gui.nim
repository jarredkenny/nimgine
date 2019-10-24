import ../types
import ../ecs
import ../ui

var guiSystem* = newSystem()

guiSystem.subscribe(@[Resize, MouseMove])

guiSystem.update = proc(world: World, system: System, event: Event, dt: float) =
  case event.kind:
    of Resize:
      ui.setDisplaySize(event.width, event.height)
    of MouseMove:
      ui.setMousePosition(event.x, event.y)
    else: discard
