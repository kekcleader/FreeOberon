MODULE SDL2;
(* Copyright 2017-2020 Arthur Yefimov

This file is part of Free Oberon.

Free Oberon is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Free Oberon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*)
IMPORT SYSTEM;
CONST
  (* SDL_Init Flags *)
  initTimer*          = 0;
  initAudio*          = 4;
  initVideo*          = 5;
  initJoystick*       = 9;
  initHaptic*         = 12;
  initGameController* = 13;
  initEvents*         = 14;
  initEverything*     = {initTimer, initAudio, initVideo, initJoystick,
                        initHaptic, initGameController, initEvents};

  (* SDL_CreateWindow Flags *)
  windowFullscreen*        = 0;
  windowOpenGL*            = 1;
  windowShown*             = 2;
  windowHidden*            = 3;
  windowBorderless*        = 4;
  windowResizable*         = 5;
  windowMinimized*         = 6;
  windowMaximized*         = 7;
  windowInputGrabbed*      = 8;
  windowInputFocus*        = 9;
  windowMouseFocus*        = 10;
  windowFullscreenDesktop* = {windowFullscreen, 12};
  windowForeign*           = 11;
  windowAllowHighDPI*      = 13;

  (* Window Position *)
  windowPosUndefined* = 1FFF0000H;

  (* Event Types *)
  firstEvent*      = 0;
  quit*            = 100H;
  windowEvent*     = 200H;
  keyDown*         = 300H;
  keyUp*           = 301H;
  textEditing*     = 302H;
  textInput*       = 303H;
  mouseMotion*     = 400H;
  mouseButtonDown* = 401H;
  mouseButtonUp*   = 402H;
  mouseWheel*      = 403H;
  userEvent*       = 8000H;
  lastEvent*       = 0FFFFH;

  (* Key Mods *)
  kmodLShift*   = 0;
  kmodRShift*   = 1;
  kmodLCtrl*    = 6;
  kmodRCtrl*    = 7;
  kmodLAlt*     = 8;
  kmodRAlt*     = 9;
  kmodLGui*     = 10;
  kmodRGui*     = 11;
  kmodNum*      = 12;
  kmodCaps*     = 13;
  kmodMode*     = 14;
  kmodReserved* = 15;
  kmodCtrl*     = {kmodLCtrl, kmodRCtrl};
  kmodShift*    = {kmodLShift, kmodRShift};
  kmodAlt*      = {kmodLAlt, kmodRAlt};
  kmodGui*      = {kmodLGui, kmodRGui};

  (* Hints (for SDL_Hint) *)
  hintFramebufferAcceleration*  = 'SDL_FRAMEBUFFER_ACCELERATION';
  hintRenderDriver*             = 'SDL_RENDER_DRIVER';
  hintRenderOpenglShaders*      = 'SDL_RENDER_OPENGL_SHADERS';
  hintRenderDirect3dThreadsafe* = 'SDL_RENDER_DIRECT3D_THREAD_SAFE';
  hintRenderScaleQuality*       = 'SDL_RENDER_SCALE_QUALITY';
  hintRenderVsync*              = 'SDL_RENDER_VSYNC';
  hintVideoAllowScreensaver*    = 'SDL_VIDEO_ALLOW_SCREENSAVER';
  hintVideoX11Xvidmode*         = 'SDL_VIDEO_X11_XVIDMODE';
  hintVideoX11Xinerama*         = 'SDL_VIDEO_X11_XINERAMA';
  hintVideoX11Xrandr*           = 'SDL_VIDEO_X11_XRANDR';
  hintGrabKeyboard*             = 'SDL_GRAB_KEYBOARD';
  hintMouseRelativeModeWarp*    = 'SDL_MOUSE_RELATIVE_MODE_WARP';
  hintVideoMinimizeOnFocusLoss* = 'SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS';
  hintIdleTimerDisabled*        = 'SDL_IOSIDLETIMERDISABLED';
  hintOrientations*             = 'SDL_IOSORIENTATIONS'; (* !FIXME add _ lol *)
  hintAccelerometerAsJoystick*  = 'SDL_ACCELEROMETERASJOYSTICK';
  hintXinputEnabled*            = 'SDL_XINPUTENABLED';
  hintGamecontrollerconfig*     = 'SDL_GAMECONTROLLERCONFIG';
  hintJoystickAllowBgEvents* = 'SDL_JOYSTICKALLOWBACKGROUNDEVENTS';
  hintAllowTopmost*                  = 'SDL_ALLOWTOPMOST';
  hintTimerResolution*               = 'SDL_TIMERRESOLUTION';
  hintVideoHighDpiDisabled*          = 'SDL_VIDEO_HIGHDPIDISABLED';
  hintMacCtrlClickEmulateRClick* = 'SDL_MACCTRLCLICKEMULATERIGHTCLICK';
  hintVideoWinD3dCompiler*           = 'SDL_VIDEO_WIND3DCOMPILER';
  hintVideoWindowSharePixelFormat*   = 'SDL_VIDEO_WINDOWSHAREPIXELFORMAT';
  hintVideoMacFullscreenSpaces*      = 'SDL_VIDEO_MACFULLSCREENSPACES';

  (* Renderer Flags *)
  rendererSoftware*      = 0;
  rendererAccelerated*   = 1;
  rendererPresentVsync*  = 2;
  rendererTargetTexture* = 3;

  (* Flip Flags*)
  flipHorizontal* = 0;
  flipVertical*   = 1;

  (* ImgInit Flags *)
  imgInitJpg*  = 0;
  imgInitPng*  = 1;
  imgInitTif*  = 2;
  imgInitWebp* = 3;

  (* Blend Modes *)
  blendModeBlend* = 0;
  blendModeAdd*   = 1;
  blendModeMod*   = 2;

  (* Mouse Buttons *)
  buttonLeft*      = 1;
  buttonMiddle*    = 2;
  buttonRight*     = 3;
  buttonWheelUp*   = 4;
  buttonWheelDown* = 5;
  buttonX1*        = 6;
  buttonX2*        = 7;

  (* Text Editing and Input *)
  textEditingEventTextSize* = 32;
  textInputEventTextSize*   = 32;

  (* PeepEvents actions *)
  addEvent*  = 0;
  peekEvent* = 1;
  getEvent*  = 2;

TYPE
  INT8* = SYSTEM.INT8;
  INT16* = SYSTEM.INT16;

  Window* = SYSTEM.PTR;

  Renderer* = SYSTEM.PTR;

  WindowEvent* = POINTER [1] TO WindowEventDesc;
  WindowEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    event*: INT16;
    data1*: INTEGER;
    data2*: INTEGER;
  END;

  Keysym* = RECORD
    scancode*: INTEGER;
    sym*: INTEGER;
    mod*: SHORTINT;
  END;

  KeyboardEvent* = POINTER [1] TO KeyboardEventDesc;
  KeyboardEventDesc = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    state*: INT16;
    repeat*: INT16;
    keysym*: Keysym;
    padding1: ARRAY 100 OF CHAR
  END;

  MouseMotionEvent* = POINTER [1] TO MouseMotionEventDesc;
  MouseMotionEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    which*: INTEGER;
    state*: INTEGER;
    x*: INTEGER;
    y*: INTEGER;
    xRel*: INTEGER;
    yRel*: INTEGER;
  END;

  MouseButtonEvent* = POINTER [1] TO MouseButtonEventDesc;
  MouseButtonEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    which*: INTEGER;
    button*: INT8;
    state*: INT8;
    clicks*: INT8;
    padding1: INT8;
    x*: INTEGER;
    y*: INTEGER;
  END;

  MouseWheelEvent* = POINTER [1] TO MouseWheelEventDesc;
  MouseWheelEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    which*: INTEGER;
    x*: INTEGER;
    y*: INTEGER;
    direction*: INTEGER;
  END;

  TextEditingEvent* = POINTER [1] TO TextEditingEventDesc;
  TextEditingEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    text*: ARRAY textEditingEventTextSize OF CHAR;
    start*: INTEGER;
    length*: INTEGER;
  END;

  TextInputEvent* = POINTER [1] TO TextInputEventDesc;
  TextInputEventDesc* = RECORD
    type*: INTEGER;
    timestamp*: INTEGER;
    windowID*: INTEGER;
    text*: ARRAY textInputEventTextSize OF CHAR;
  END;

  Event* = RECORD
    type*: INTEGER;
    padding1: ARRAY 124 OF CHAR
  END;

  Rect* = RECORD
    x*, y*, w*, h*: INTEGER
  END;

  Palette* = POINTER [1] TO PaletteDesc;
  PaletteDesc* = RECORD
    nColors: INTEGER;
    colors: SYSTEM.PTR;
    version: INTEGER;
    refCount: INTEGER
  END;

  DisplayMode* = RECORD
    format*: INTEGER;
    w*, h*: INTEGER;
    refreshRate*: INTEGER;
    driverData: SYSTEM.PTR
  END;

  PixelFormat* = POINTER [1] TO PixelFormatDesc;
  PixelFormatDesc* = RECORD
    format*: INTEGER;
    palette*: Palette;
    bitsPerPixel*: INT16;
    bytesPerPixel*: INT16;
    rMask*: INTEGER;
    gMask*: INTEGER;
    aMask*: INTEGER;
    padding1: ARRAY 16 OF CHAR
  END;

  Surface* = POINTER [1] TO SurfaceDesc;
  SurfaceDesc* = RECORD
    flags: INTEGER;
    format*: PixelFormat;
    w*, h*, pitch*: INTEGER;
    pixels*: SYSTEM.PTR;
    userData*: SYSTEM.PTR;
    locked: INTEGER;
    lockData: SYSTEM.PTR;
    clipRect*: Rect;
    map: SYSTEM.PTR;
    refCount*: INTEGER
  END;

  Texture* = SYSTEM.PTR;

  KeyArray* = POINTER [1] TO ARRAY 1024 OF BOOLEAN;

PROCEDURE -AAIncludeSDL2h0* '#include "SDL2.h0"';

PROCEDURE -Init*(flags: SET): SHORTINT "SDL_Init(flags)";
PROCEDURE -Quit* "SDL_Quit()";

PROCEDURE -CreateWindow*(title: ARRAY OF CHAR; x, y, w, h: INTEGER;
    flags: SET): Window "(void *)SDL_CreateWindow(title, x, y, w, h, flags)";
PROCEDURE -GetWindowSize*(window: Window; VAR w, h: INTEGER)
    "SDL_GetWindowSize(window, w, h)";
PROCEDURE -SetWindowSize*(window: Window; w, h: INTEGER)
    "SDL_SetWindowSize(window, w, h)";
PROCEDURE -DestroyWindow(win: SYSTEM.PTR) "SDL_DestroyWindow(win)";

PROCEDURE -PollEvent*(VAR e: Event): INTEGER "SDL_PollEvent(e)";
PROCEDURE -WaitEvent*(VAR e: Event): INTEGER "SDL_WaitEvent(e)";
PROCEDURE -WaitEventTimeout*(VAR e: Event; timeout: INTEGER): INTEGER
    "SDL_WaitEventTimeout(e, timeout)";

PROCEDURE -PumpEvents* "SDL_PumpEvents()";
PROCEDURE -PeepEvents*(events: ARRAY OF Event; numevents, action,
    minType, maxType: INTEGER): INTEGER
    "SDL_PeepEvents(events, numevents, action, minType, maxType)";

PROCEDURE -HasEvent*(type: INTEGER): INTEGER "SDL_HasEvent(type)";
PROCEDURE -HasEvents*(minType, maxType: INTEGER): INTEGER
    "SDL_HasEvents(minType, maxType)";

PROCEDURE -StartTextInput* "SDL_StartTextInput()";
PROCEDURE -StopTextInput* "SDL_StopTextInput()";

PROCEDURE -SetColorKey*(surface: Surface; flag: INTEGER; key: INTEGER)
    "SDL_SetColorKey(surface, flag, key)";

PROCEDURE -MapRGB*(format: PixelFormat; r, g, b: SHORTINT): INTEGER
    "SDL_MapRGB(format, r, g, b)";

PROCEDURE -RWFromFile*(fname, mode: ARRAY OF CHAR): SYSTEM.PTR
    "SDL_RWFromFile(fname, mode)";
PROCEDURE -LoadBmpRW*(src: SYSTEM.PTR; freeSrc: INTEGER): Surface
    "(void *)SDL_LoadBMP_RW(src, freeSrc)";

(* SDL Image Addon *)

PROCEDURE -ImgInit*(flags: SET): SET "IMG_Init(flags)";
PROCEDURE -ImgQuit* "IMG_Quit()";
PROCEDURE -ImgLoad*(file: ARRAY OF CHAR): Surface
    "(void *)IMG_Load(file)";

(* Renderer *)

PROCEDURE -CreateRenderer*(win: Window; index: INTEGER;
    flags: SET): Renderer "(void *)SDL_CreateRenderer(win, index, flags)";
PROCEDURE -SetRenderDrawColor*(renderer: Renderer; r, g, b, a: SHORTINT)
    "SDL_SetRenderDrawColor(renderer, r, g, b, a)";
PROCEDURE -RenderClear*(renderer: Renderer) "SDL_RenderClear(renderer)";
PROCEDURE -RenderPresent*(renderer: Renderer) "SDL_RenderPresent(renderer)";
PROCEDURE -RenderDrawLine*(renderer: Renderer; x1, y1, x2, y2: INTEGER)
    "SDL_RenderDrawLine(renderer, x1, y1, x2, y2)";
PROCEDURE -RenderDrawPoint*(renderer: Renderer; x, y: INTEGER)
    "SDL_RenderDrawPoint(renderer, x, y)";
PROCEDURE -RenderDrawRect*(renderer: Renderer; VAR rect: Rect)
    "SDL_RenderDrawRect(renderer, rect)";
PROCEDURE -RenderFillRect*(renderer: Renderer; VAR rect: Rect)
    "SDL_RenderFillRect(renderer, rect)";
PROCEDURE -RenderSetLogicalSize*(renderer: Renderer; w, h: INTEGER)
    "SDL_RenderSetLogicalSize(renderer, w, h)";
PROCEDURE -RenderCopy*(renderer: Renderer; texture: Texture;
    VAR srcRect, dstRect: Rect)
    "SDL_RenderCopy(renderer, texture, srcRect, dstRect)";
PROCEDURE -RenderCopyNil*(renderer: Renderer; texture: Texture)
    "SDL_RenderCopy(renderer, texture, (void *)0, (void *)0)";
(*PROCEDURE -RenderCopyEx*(renderer: Renderer; texture: Texture;
    VAR srcRect, dstRect: Rect; angle: REAL; center: Point; flip: SET)
    "SDL_RenderCopyEx(renderer, texture, srcRect, dstRect, angle, center, flip)";*)
PROCEDURE -SetRenderDrawBlendMode*(renderer: Renderer; blendMode: SET)
    "SDL_SetRenderDrawBlendMode(renderer, blendMode)";
PROCEDURE -DestroyRenderer(renderer: SYSTEM.PTR) "SDL_DestroyRenderer(renderer)";

(* Misc *)

PROCEDURE -Delay*(ms: INTEGER) "SDL_Delay(ms)";
PROCEDURE -SetHint*(name: ARRAY OF CHAR; value: ARRAY OF CHAR)
    "SDL_SetHint(name, value)";
PROCEDURE -ShowCursor*(toggle: SHORTINT) "SDL_ShowCursor(toggle)";
PROCEDURE -GetError*(): SYSTEM.PTR "SDL_GetError()";
PROCEDURE -SDLGetKeyboardState(VAR numKeys: INTEGER): SYSTEM.PTR
    "(void *)SDL_GetKeyboardState(numKeys)";

PROCEDURE -GetDesktopDisplayMode*(displayIndex: INTEGER; VAR mode: DisplayMode)
    "SDL_GetDesktopDisplayMode(displayIndex, mode)";

PROCEDURE -FillRect*(dst: Surface; VAR rect: Rect; color: INTEGER)
  "SDL_FillRect(dst, rect, color)";

PROCEDURE -FillRectNil*(dst: Surface; color: INTEGER)
  "SDL_FillRect(dst, (void *)0, color)"; (* !FIXME *)

PROCEDURE -LockSurface*(surface: Surface) "SDL_LockSurface(surface)";
PROCEDURE -UnlockSurface*(surface: Surface) "SDL_UnlockSurface(surface)";
PROCEDURE -FreeSurface*(surface: Surface) "SDL_FreeSurface(surface)";

PROCEDURE -CreateRGBSurface*(flags, w, h, depth: INTEGER;
    rMask, gMask, bMask, aMask: LONGINT): Surface
    "(void *)SDL_CreateRGBSurface(flags, w, h, depth, rMask, gMask, bMask, aMask)";

PROCEDURE -BlitSurface*(src: Surface; VAR srcRect: Rect;
    dst: Surface; VAR dstRect: Rect) "SDL_UpperBlit(src, srcRect, dst, dstRect)";
PROCEDURE -BlitSurfaceNil*(src: Surface;
    dst: Surface; VAR dstRect: Rect) "SDL_UpperBlit(src, (void *)0, dst, dstRect)";
PROCEDURE -BlitScaled*(src: Surface; VAR srcRect: Rect;
    dst: Surface; VAR dstRect: Rect) "SDL_UpperBlitScaled(src, srcRect, dst, dstRect)";

PROCEDURE -ConvertSurface*(src: Surface; fmt: PixelFormat;
    flags: INTEGER): Surface "(void *)SDL_ConvertSurface(src, fmt, flags)";

PROCEDURE -SetSurfaceColorMod*(surface: Surface; r, g, b: INTEGER)
    "SDL_SetSurfaceColorMod(surface, r, g, b)";

PROCEDURE -GetKeyboardState*(VAR numKeys: INTEGER): KeyArray
    "SDL_GetKeyboardState(numKeys)";

PROCEDURE -GetKeyboardStateNil*(): KeyArray "(void *)SDL_GetKeyboardState((void *)0)";

PROCEDURE -GetMouseState*(VAR x, y: INTEGER): INTEGER "SDL_GetMouseState(x, y)";

PROCEDURE -GetWindowFlags*(window: Window): SET "SDL_GetWindowFlags(window)";

PROCEDURE -SetWindowTitle*(window: Window; title: ARRAY OF CHAR)
    "SDL_SetWindowTitle(window, title)";

PROCEDURE -CreateTextureFromSurface*(renderer: Renderer; surface: Surface): Texture
    "(void *)SDL_CreateTextureFromSurface(renderer, surface)";

PROCEDURE -DestroyTexture*(texture: Texture) "SDL_DestroyTexture(texture)";

PROCEDURE -GetTicks*(): INTEGER "SDL_GetTicks()";

PROCEDURE -SetWindowFullscreen*(win: Window; flags: SET): INTEGER
    "SDL_SetWindowFullscreen(win, flags)";

PROCEDURE -SetSurfaceAlphaMod*(surface: Surface; alpha: CHAR): INTEGER
    "SDL_SetSurfaceAlphaMod(surface, alpha)";

END SDL2.
