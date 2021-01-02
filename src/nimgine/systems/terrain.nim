import strformat, sequtils, sets
import ../types
import ../ecs
import ../renderer
import ../debug

var terrainSystem* = newSystem(false)

terrainSystem.matchComponent(Terrain)
terrainSystem.matchComponent(Model)

terrainSystem.update = proc(universe: Universe, system: System, dt: float) =
  for entity in universe.entitiesWith(system.components):
    echo repr(entity)

  # for entity in  universe.entitiesForSystem(terrainSystem):
    # discard
    # UNIV: get component for model
    # var terrain = entity.get(Terrain)
    # terrain.size = terrainSize.int
    # terrain.density = terrainDensity.int
    # terrain.octaves = terrainOctaves.int
    # terrain.amplitude = terrainAmp
    # terrain.spreadX = terrainSpreadX
    # terrain.spreadZ = terrainSpreadZ 
    # terrain.persistence = terrainPersistence

  
    # entity.set(newTerrainModel(terrain, app.world.viewer, terrainRenderDistance.int))