import strformat
import ../types
import ../ecs
import ../renderer
import ../debug

var terrainSystem* = newSystem(false)

terrainSystem.matchComponent(Terrain)

terrainSystem.preRender = proc(scene: Scene, world: World) =
  for entity in  world.entitiesForSystem(terrainSystem):
    var terrain = entity.get(Terrain)
    terrain.size = terrainSize
    terrain.density = terrainDensity
    terrain.amplitude = terrainAmp
    terrain.spread = terrainSpread

    entity.add(newModel(newTerrainMesh(terrain)))