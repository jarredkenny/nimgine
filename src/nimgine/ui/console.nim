import ../types
import ../ui

var window = newUIWindow("Console")

var console = newUIConsole(100)
var input = newUIInput()

proc handleInputEnter() =
  console.write(input.buffer)

input.handleEnter = handleInputEnter

window.add(console)
window.add(input)


var consoleWindow* = window
