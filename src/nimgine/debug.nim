import types

var DebugLayer* = ApplicationLayer()

DebugLayer.init = proc(app: Application) =

  var window = UIWindow(name: "Debug", open: true)



  app.windows.add(window)

DebugLayer.update = proc(app: Application) = discard
