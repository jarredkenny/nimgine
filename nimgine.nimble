# Package

version       = "0.1.0"
author        = "Jarred Kenny"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["nimgine"]
backend       = "c"


# Dependencies

requires "nim >= 1.0.0"
requires "sdl2 >= 2.0.1"
requires "opengl >= 1.2.2"
requires "glm >= 1.1.1"
requires "imgui >= 1.73.0"
requires "nimassets >= 0.1.0"
requires "assimp >= 0.1.1"