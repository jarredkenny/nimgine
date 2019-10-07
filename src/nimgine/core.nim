import platform
import ecs

platform.init()

proc loop(dt: float) =
  echo "Game Loop"

platform.setGameLoopFunc(loop)
