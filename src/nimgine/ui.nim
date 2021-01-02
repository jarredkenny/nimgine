import deques, strformat, tables
import sdl2, opengl, imgui
import types, events, input, logger

var UILayer* = ApplicationLayer()

var
  gMouseCursors: array[ImGuiMouseCursor.high.int32 + 1, CursorPtr]
  gFontTexture: uint32
  gShaderHandle: uint32
  gVertHandle: uint32
  gFragHandle: uint32
  gAttribLocationTex: int32
  gAttribLocationProjMtx: int32
  gAttribLocationPosition: int32
  gAttribLocationUV: int32
  gAttribLocationColor: int32
  gVboHandle: uint32
  gElementsHandle: uint32
  gKeyboardCharInputLock: bool
  gWindowWidth: int32
  gWindowHeight: int32
  gCaptureMouse: bool
  elementCount: int
  windowCount: int

proc igOpenGL3CheckProgram(handle: uint32, desc: string) =
  var status: int32
  var log_length: int32
  glGetProgramiv(handle, GL_LINK_STATUS, status.addr)
  glGetProgramiv(handle, GL_INFO_LOG_LENGTH, log_length.addr)
  if status == GL_FALSE.int32:
    echo "ERROR: impl_opengl failed to link " & desc
  if log_length > 0:
    var msg: seq[char] = newSeq[char](log_length)
    glGetProgramInfoLog(handle, log_length, nil, msg[0].addr)
    for m in msg:
      stdout.write(m)
    echo ""

proc igOpenGL3CheckShader(handle: uint32, desc: string) =
  var status: int32
  var log_length: int32
  glGetShaderiv(handle, GL_COMPILE_STATUS, status.addr)
  glGetShaderiv(handle, GL_INFO_LOG_LENGTH, log_length.addr)
  if status == GL_FALSE.int32:
    echo "ERROR: impl_opengl failed to compile " & desc
  if log_length > 0:
    var msg: seq[char] = newSeq[char](log_length)
    glGetShaderInfoLog(handle, log_length, nil, msg[0].addr)
    for m in msg:
      stdout.write(m)
    echo ""

proc igOpenGL3CreateFontsTexture() =
  let io = igGetIO()
  var text_pixels: ptr cuchar
  var text_w: int32
  var text_h: int32
  io.fonts.getTexDataAsRGBA32(text_pixels.addr, text_w.addr, text_h.addr)

  var last_texture: int32
  glGetIntegerv(GL_TEXTURE_BINDING_2D, last_texture.addr)
  glGenTextures(1, gFontTexture.addr)
  glBindTexture(GL_TEXTURE_2D, gFontTexture)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.ord)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.ord)
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.ord, text_w, text_h, 0, GL_RGBA,
      GL_UNSIGNED_BYTE, text_pixels)

  io.fonts.texID = cast[ImTextureID](gFontTexture)
  glBindTexture(GL_TEXTURE_2D, last_texture.uint32)


proc igOpenGL3CreateDeviceObjects() =
  var last_texture: int32
  var last_array_buffer: int32
  var last_vertex_array: int32
  glGetIntegerv(GL_TEXTURE_BINDING_2D, last_texture.addr)
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, last_array_buffer.addr)
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, last_vertex_array.addr)

  # @NOTE: if you need the other shader versions, PR them please.
  var vertex_shader_glsl: cstringarray = allocCStringArray([
  """
  #version 330 core
  layout (location = 0) in vec2 Position;
  layout (location = 1) in vec2 UV;
  layout (location = 2) in vec4 Color;
  uniform mat4 ProjMtx;
  out vec2 Frag_UV;
  out vec4 Frag_Color;
  void main() {
    Frag_UV = UV;
    Frag_Color = Color;
    gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
  }
  """
  ])
  var fragment_shader_glsl: cstringarray = allocCStringArray([
  """
    #version 330 core
    in vec2 Frag_UV;
    in vec4 Frag_Color;
    uniform sampler2D Texture;
    layout (location = 0) out vec4 Out_Color;
    void main() {
      Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
    }
  """
  ])

  gVertHandle = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(gVertHandle.GLuint, 1.GLsizei, vertex_shader_glsl, nil)
  glCompileShader(gVertHandle)
  igOpenGL3CheckShader(gVertHandle, "vertex shader")

  gFragHandle = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(gFragHandle.GLuint, 1.GLsizei, fragment_shader_glsl, nil)
  glCompileShader(gFragHandle)
  igOpenGL3CheckShader(gFragHandle, "fragment shader")

  gShaderHandle = glCreateProgram()
  glAttachShader(gShaderHandle, gVertHandle)
  glAttachShader(gShaderHandle, gFragHandle)
  glLinkProgram(gShaderHandle)
  igOpenGL3CheckProgram(gShaderHandle, "shader program")

  gAttribLocationTex = glGetUniformLocation(gShaderHandle, "Texture")
  gAttribLocationProjMtx = glGetUniformLocation(gShaderHandle, "ProjMtx")
  gAttribLocationPosition = glGetAttribLocation(gShaderHandle, "Position")
  gAttribLocationUV = glGetAttribLocation(gShaderHandle, "UV")
  gAttribLocationColor = glGetAttribLocation(gShaderHandle, "Color")

  glGenBuffers(1, gVboHandle.addr)
  glGenBuffers(1, gElementsHandle.addr)

  igOpenGL3CreateFontsTexture()

  glBindTexture(GL_TEXTURE_2D, last_texture.uint32)
  glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer.uint32)
  glBindVertexArray(last_vertex_array.uint32)

proc igOpenGL3RenderDrawData*() =
  let data: ptr ImDrawData = igGetDrawData()
  let io = igGetIO()
  let fb_width = (data.displaySize.x * io.displayFramebufferScale.x).int32
  let fb_height = (data.displaySize.y * io.displayFramebufferScale.y).int32
  if fb_width <= 0 or fb_height <= 0:
    return
  data.scaleClipRects(io.displayFramebufferScale)

  var
    last_active_texture: int32
    last_program: int32
    last_texture: int32
    last_array_buffer: int32
    last_vertex_array: int32
    last_viewport: array[4, int32]
    last_scissor_box: array[4, int32]
    last_blend_src_rgb: int32
    last_blend_dst_rgb: int32
    last_blend_src_alpha: int32
    last_blend_dst_alpha: int32
    last_blend_equation_rgb: int32
    last_blend_equation_alpha: int32
    last_enable_blend: bool
    last_enable_cull_face: bool
    last_enable_depth_test: bool
    last_enable_scissor_test: bool

  glGetIntegerv(GL_ACTIVE_TEXTURE, last_active_texture.addr)
  glActiveTexture(GL_TEXTURE_0)
  glGetIntegerv(GL_CURRENT_PROGRAM, last_program.addr)
  glGetIntegerv(GL_TEXTURE_BINDING_2D, last_texture.addr)
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, last_array_buffer.addr)
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, last_vertex_array.addr)
  glGetIntegerv(GL_VIEWPORT, last_viewport[0].addr)
  glGetIntegerv(GL_SCISSOR_BOX, last_scissor_box[0].addr)
  glGetIntegerv(GL_BLEND_SRC_RGB, last_blend_src_rgb.addr)
  glGetIntegerv(GL_BLEND_DST_RGB, last_blend_dst_rgb.addr)
  glGetIntegerv(GL_BLEND_SRC_ALPHA, last_blend_src_alpha.addr)
  glGetIntegerv(GL_BLEND_DST_ALPHA, last_blend_dst_alpha.addr)
  glGetIntegerv(GL_BLEND_EQUATION_RGB, last_blend_equation_rgb.addr)
  glGetIntegerv(GL_BLEND_EQUATION_ALPHA, last_blend_equation_alpha.addr)
  last_enable_blend = glIsEnabled(GL_BLEND)
  last_enable_cull_face = glIsEnabled(GL_CULL_FACE)
  last_enable_depth_test = glIsEnabled(GL_DEPTH_TEST)
  last_enable_scissor_test = glIsEnabled(GL_SCISSOR_TEST)

  glEnable(GL_BLEND)
  glBlendEquation(GL_FUNC_ADD)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)
  glEnable(GL_SCISSOR_TEST)

  glViewport(0, 0, fb_width, fb_height)
  let L: float32 = data.displayPos.x
  let R: float32 = data.displayPos.x + data.displaySize.x
  let T: float32 = data.displayPos.y
  let B: float32 = data.displayPos.y + data.displaySize.y
  var ortho_projection: array[4, array[4, float32]] = [
    [2.0f/(R-L), 0.0f, 0.0f, 0.0f],
    [0.0f, 2.0f/(T-B), 0.0f, 0.0f],
    [0.0f, 0.0f, -1.0f, 0.0f],
    [(R+L)/(L-R), (T+B)/(B-T), 0.0f, 1.0f],
  ]
  glUseProgram(gShaderHandle)
  glUniform1i(gAttribLocationTex, 0)
  glUniformMatrix4fv(gAttribLocationProjMtx, 1, false, ortho_projection[0][0].addr)

  var vaoHandle: uint32 = 0
  glGenVertexArrays(1, vaoHandle.addr)
  glBindVertexArray(vaoHandle)
  glBindBuffer(GL_ARRAY_BUFFER, gVboHandle)
  glEnableVertexAttribArray(gAttribLocationPosition.uint32)
  glEnableVertexAttribArray(gAttribLocationUV.uint32)
  glEnableVertexAttribArray(gAttribLocationColor.uint32)
  glVertexAttribPointer(gAttribLocationPosition.uint32, 2, cGL_FLOAT,
      false, ImDrawVert.sizeof().int32, cast[pointer](0))
  glVertexAttribPointer(gAttribLocationUV.uint32, 2, cGL_FLOAT, false,
      ImDrawVert.sizeof().int32, cast[pointer](8))
  glVertexAttribPointer(gAttribLocationColor.uint32, 4, GL_UNSIGNED_BYTE, true,
      ImDrawVert.sizeof().int32, cast[pointer](16))

  let pos = data.displayPos
  for n in 0 ..< data.cmdListsCount:
    var cmd_list = data.cmdLists[n]
    var idx_buffer_offset: int = 0

    glBindBuffer(GL_ARRAY_BUFFER, gVboHandle)
    glBufferData(GL_ARRAY_BUFFER, (cmd_list.vtxBuffer.size * ImDrawVert.sizeof(
      )).int32, cmd_list.vtxBuffer.data[0].addr, GL_STREAM_DRAW)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gElementsHandle)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (cmd_list.idxBuffer.size *
        ImDrawIdx.sizeof()).int32, cmd_list.idxBuffer.data[0].addr, GL_STREAM_DRAW)

    for cmd_i in 0 ..< cmd_list.cmdBuffer.size:
      var pcmd = cmd_list.cmdBuffer.data[cmd_i]

      if pcmd.userCallback != nil:
        pcmd.userCallback(cmd_list, pcmd.addr)
      else:
        var clip_rect = ImVec4(x: pcmd.clipRect.x - pos.x, y: pcmd.clipRect.y -
            pos.y, z: pcmd.clipRect.z - pos.x, w: pcmd.clipRect.w - pos.y)
        if clip_rect.x < fb_width.float32 and clip_rect.y <
            fb_height.float32 and clip_rect.z >= 0.0f and clip_rect.w >= 0.0f:
          glScissor(clip_rect.x.int32, (fb_height.float32 - clip_rect.w).int32,
              (clip_rect.z - clip_rect.x).int32, (clip_rect.w -
              clip_rect.y).int32)
          glBindTexture(GL_TEXTURE_2D, cast[uint32](pcmd.textureId))
          glDrawElements(GL_TRIANGLES, pcmd.elemCount.int32,
              if ImDrawIdx.sizeof == 2: GL_UNSIGNED_SHORT else: GL_UNSIGNED_INT,
              cast[pointer](idx_buffer_offset))
        idx_buffer_offset.inc(pcmd.elemCount.int32 * ImDrawIdx.sizeof())

  glDeleteVertexArrays(1, vaoHandle.addr)

  # Restore modified GL State
  glUseProgram(last_program.uint32)
  glBindTexture(GL_TEXTURE_2D, last_texture.uint32)
  glActiveTexture(last_active_texture.GLenum)
  glBindVertexArray(last_vertex_array.uint32)
  glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer.uint32)
  glBlendEquationSeparate(last_blend_equation_rgb.Glenum,
      last_blend_equation_alpha.Glenum)
  glBlendFuncSeparate(last_blend_src_rgb.GLenum, last_blend_dst_rgb.GLenum,
      last_blend_src_alpha.GLenum, last_blend_dst_alpha.GLenum)

  if last_enable_blend: glEnable(GL_BLEND) else: glDisable(GL_BLEND)
  if last_enable_cull_face: glEnable(GL_CULL_FACE) else: glDisable(GL_CULL_FACE)
  if last_enable_depth_test: glEnable(GL_DEPTH_TEST) else: glDisable(GL_DEPTH_TEST)
  if last_enable_scissor_test: glEnable(GL_SCISSOR_TEST) else: glDisable(GL_SCISSOR_TEST)

  glViewport(last_viewport[0], last_viewport[1], last_viewport[2],
      last_viewport[3])
  glScissor(last_scissor_box[0], last_scissor_box[1], last_scissor_box[2],
      last_scissor_box[3])

proc push*(window: UIWindow, element: UIELement) =
  element.window = window
  window.elements.add(element)

proc newUIWindow*(name: string, open: bool = true): UIWindow =
  windowCount += 1
  result = UIWindow(id: windowCount)

proc add*(window: UIWindow, element: UIElement) =
  window.elements.add(element)

proc newUIText*(value: string): UIElement =
  elementCount += 1
  result = UIElement(id: elementCount, kind: UIText, text: value)

proc newUISlider*(name: string, value: ptr float32, min, max: float): UIElement =
  elementCount += 1
  result = UIElement(id: elementCount, kind: UISlider, name: name, min: min, max: max, value: value)

proc newUIButton*(label: string): UIELement =
  elementCount += 1
  result = UIElement(id: elementCount, kind: UIButton, label: label)

proc newUIInput*(onEnter: proc(e: UIElement) ): UIElement =
  elementCount += 1
  let element = UIElement(id: elementCount, kind: UIInput, buffer: "", onEnter: onEnter)
  element.buffer.setLen(100)
  result = element

proc newUIRow*(children: seq[UIElement]): UIElement =
  elementCount += 1
  result = UIElement(id: elementCount, kind: UIRow, children: children)

proc newUIEntityTree*(entities: seq[Entity]): UIElement =
  elementCount += 1
  result = UIElement(id: elementCount, kind: UIEntityTree, entities: entities)

proc newUIConsole*(history: int): UIElement =
  elementCount += 1
  result = UIElement(
    id: elementCount,
    kind: UIConsole,
    history: history,
    lines: initDeque[string](),
    scrollToBottom: true
  )

proc write*(elem: UIElement, line: string) =
  assert elem.kind == UIConsole
  if elem.lines.len > elem.history:
    discard elem.lines.popFirst()
  elem.lines.addLast(line)

proc draw(element: UIElement) =
  case element.kind:
    of UIText:
      igText(element.text)
    of UIButton:
      if igButton(element.label) and element.handler != nil:
        element.handler()
    of UIInput:
      if igInputText("input".cstring, element.buffer.cstring, (
          element.buffer.len * sizeof(char) + 1).uint,
              ImGuiInputTextFlags.EnterReturnsTrue):
        element.onEnter(element)
        igSetKeyboardFocusHere()
    of UISlider:
      igSliderFloat(element.name.cstring, element.value, element.min, element.max)
    of UIRow:
      for child in element.children:
        draw(child)
        if child != element.children[element.children.len - 1]:
          igSameLine()
    of UIConsole:
      var footHeight = igGetStyle().itemSpacing.y +
          igGetFrameHeightWithSpacing()
      igBeginChild("console".cstring, ImVec2(x: 0, y: -footHeight), true, HorizontalScrollbar)
      for line in element.lines:
        igTextUnformatted(line)
      if igGetScrollY() == igGetScrollMaxY():
        igSetScrollHereY(1.0.float32)
      igEndChild()
    of UIEntityTree:
      discard
      # igPushId(element.window.id.int32)
      # let flags = (ImGuiTreeNodeFlags.Leaf.int32 or ImGuiTreeNodeFlags.NoTreePushOnOpen.int32 or ImGuiTreeNodeFlags.Bullet.int32).ImGuiTreeNodeFlags
      # for id, entity in element.entities:
      #   igPushID(id.int32)
      #   let node_open = igTreeNode("Object", "%s %i", $entity.typeof, id.int32)
      #   if node_open:
      #     for component in keys(entity.components):
      #         igPushID(entity.components[component].addr)
      #         if igTreeNode("Object", "%s", component):
      #           igText(repr(entity.components[component][]))
      #           igTreePop()
      #         igPopId()
      #     igTreePop()
      #   igPopID()
      # igPopId()

proc draw(window: UIWindow) =
  igBegin(window.name, window.open.addr)
  for element in window.elements:
    draw(element)
  igEnd()
  # igShowMetricsWindow()
  window.elements = @[]

proc init*(app: Application) =
  var (width, height) = sdl2.getSize(app.window)

  app.logger.log(fmt"imgui v{igGetVersion()}")

  igCreateContext()

  var io = igGetIO()

  io.displaySize = ImVec2(x: width.float32, y: height.float32)
  io.displayFramebufferScale = ImVec2(x: 1.float32, y: 1.float32)

  io.backendFlags = (io.backendFlags.int32 or
      ImGuiBackendFlags.HasMouseCursors.int32).ImGuiBackendFlags
  io.backendFlags = (io.backendFlags.int32 or
      ImGuiBackendFlags.HasSetMousePos.int32).ImGuiBackendFlags

  io.keyMap[ImGuiKey.Tab.ord] = InputType.KeyTab.ord;
  io.keyMap[ImGuiKey.LeftArrow.int32] = InputType.KeyArrowLeft.ord;
  io.keyMap[ImGuiKey.RightArrow.int32] = InputType.KeyArrowRight.ord;
  io.keyMap[ImGuiKey.UpArrow.int32] = InputType.KeyArrowUp.ord;
  io.keyMap[ImGuiKey.DownArrow.int32] = InputType.KeyArrowDown.ord;
  io.keyMap[ImGuiKey.PageUp.int32] = InputType.KeyPageUp.ord;
  io.keyMap[ImGuiKey.PageDown.int32] = InputType.KeyPageDown.ord;
  io.keyMap[ImGuiKey.Home.int32] = InputType.KeyHome.ord;
  io.keyMap[ImGuiKey.End.int32] = InputType.KeyEnd.ord;
  io.keyMap[ImGuiKey.Insert.int32] = InputType.KeyInsert.ord;
  io.keyMap[ImGuiKey.Delete.int32] = InputType.KeyDelete.ord;
  io.keyMap[ImGuiKey.Backspace.ord] = InputType.KeyBackspace.ord;
  io.keyMap[ImGuiKey.Space.int32] = InputType.KeySpace.ord;
  io.keyMap[ImGuiKey.Enter.int32] = InputType.KeyEnter.ord;
  io.keyMap[ImGuiKey.Escape.int32] = InputType.KeyEscape.ord;
  io.keyMap[ImGuiKey.KeyPadEnter.int32] = InputType.KeyKPEnter.ord;

  gMouseCursors[ImGuiMouseCursor.Arrow.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
  gMouseCursors[ImGuiMouseCursor.TextInput.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_IBEAM)
  gMouseCursors[ImGuiMouseCursor.ResizeAll.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
  gMouseCursors[ImGuiMouseCursor.ResizeNS.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENS)
  gMouseCursors[ImGuiMouseCursor.ResizeEW.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE)
  gMouseCursors[ImGuiMouseCursor.ResizeNESW.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW)
  gMouseCursors[ImGuiMouseCursor.ResizeNWSE.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE)
  gMouseCursors[ImGuiMouseCursor.Hand.int32] = createSystemCursor(SDL_SYSTEM_CURSOR_HAND)

proc poll(app: Application) =

  let io = igGetIO()

  # Generate MousePosition event if imgui wants to set a mouse position
  if io.wantSetMousePos:
    app.bus.queueEvent(types.Event(kind: MousePosition, x: io.mousePos.x.cint,
        y: io.mousePos.y.cint))

  # Generate LockKeyboardInput and UnlockKeyboardInput events
  # when io.wantCapturekeyboard changes
  if io.wantCaptureKeyboard and not gKeyboardCharInputLock:
    app.bus.queueEvent(types.Event(kind: LockKeyboardInput))
    gKeyboardCharInputLock = true

  elif not io.wantCaptureKeyboard and gKeyboardCharInputLock:
    app.bus.queueEvent(types.Event(kind: UnlockKeyboardInput))
    gKeyboardCharInputLock = false

proc handle(app: Application, event: types.Event) =

  var io = igGetIO()

  if event.kind == Resize:
    io.displaySize = ImVec2(x: event.width.float32, y: event.height.float32)

  if event.kind == MouseMove:
    io.mousePos = ImVec2(x: event.x.float32, y: event.y.float32)
    if io.wantCaptureMouse:
      event.markHandled()

  if event.kind == Charecter:
    io.addInputCharacter(event.charecter.uint32)
    event.markHandled()

  if event.kind == types.EventType.Input:

    # Handle Key Inputs
    if event.input in input.KeyEvents and io.wantCaptureKeyboard:
      io.keysDown[event.input.ord] = event.state
      event.markHandled()

    if not io.wantCaptureMouse:
      return

    # Handle Mouse Inputs
    case event.input:
      of MouseLeft:
        io.mouseDown[0] = event.state
        if event.state: event.markHandled()
      of MouseRight:
        io.mouseDown[1] = event.state
        if event.state: event.markHandled()
      of MouseScrollUp:
        io.mouseWheel += 0.5
        event.markHandled()
      of MouseScrollDown:
        io.mouseWheel -= 0.5
        event.markHandled()
      else: discard


proc render(app: Application) =
  igOpenGL3CreateDeviceObjects()
  igNewFrame()
  # igShowDemoWindow()
  for window in app.windows:
    if window.open:
      window.draw()
  igRender()
  igOpenGL3RenderDrawData()

UILayer.init = init
UILayer.poll = poll
UILayer.handle = handle
UILayer.render = render
UILayer.syncToFrame = true