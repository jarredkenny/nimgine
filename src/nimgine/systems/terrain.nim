import strformat
import ../types
import ../ecs
import ../renderer
import ../debug

var terrainSystem* = newSystem(false)

terrainSystem.matchComponent(Terrain)
terrainSystem.matchComponent(Model)

terrainSystem.update = proc(app: Application, system: System, dt: float) =
  for entity in  app.world.entitiesForSystem(terrainSystem):
    var terrain = entity.get(Terrain)
    terrain.size = terrainSize.int
    terrain.density = terrainDensity.int
    terrain.octaves = terrainOctaves.int
    terrain.amplitude = terrainAmp
    terrain.spreadX = terrainSpreadX
    terrain.spreadZ = terrainSpreadZ 
    terrain.persistence = terrainPersistence

  
    entity.set(newTerrainModel(terrain, app.world.viewer, terrainRenderDistance.int))