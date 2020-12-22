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
requires "stb_image >= 2.5"
requires "nimassets >= 0.1.0"
requires "https://github.com/nimgl/imgui.git 1.77.0"
requires "https://github.com/jarredkenny/nimassimp.git"
requires "perlin >= 0.7.0"
requires "memo >= 0.3.0"