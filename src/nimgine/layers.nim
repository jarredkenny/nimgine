import events

type
  Layer = ref object
    id: int
    name: string
    init: proc
    update: proc
    handle: proc(e: Event)
    destroy: proc

var layerCount: int = 0

proc newLayer*(name, init, update, handle, destroy): Layer =
  inc(layerCount)
  result = Layer(
    id: layerCount,
    name: name,
    init: init,
    update: update,
    handle: handle,
    destroy: destroy
  )
