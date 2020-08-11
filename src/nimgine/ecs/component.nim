import ../types

var componentCount: int = 0

proc `$`*(c: Component): string =
  result = "<Component id=" & $c.id & ">"

proc newComponent*(T: typedesc): T =
  inc(componentCount)
  result = T(id: componentCount)
