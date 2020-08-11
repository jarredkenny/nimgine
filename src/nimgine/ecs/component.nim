import ../types

var componentCount: int = 0

proc `$`*(c: Component): string =
  result = "<Component id=" & $c.id & ">"

proc newComponent*(T: typedesc): T =
  inc(componentCount)
  result = T(id: componentCount)

proc newPosition*(x, y, z: float): Position =
  result = newComponent(Position)
  result.x = x
  result.y = y
  result.z = z

proc newOrientation*(): Orientation =
  result = newComponent(Orientation)
  result.pitch = 0.0
  result.yaw = -90.0
  result.roll = 0.0

proc newMesh*(file: string): Mesh =
  var mesh: Mesh = newComponent(Mesh)
  mesh.initialized = false
  mesh.file = file
  result = mesh