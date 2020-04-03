MODULE Allegro;
(* Copyright 2019-2020 Arthur Yefimov

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
  systemAutodetect* = 0;
  systemNone*       = 1; (*!FIXME*)

  gfxText*                 = -1;
  gfxAutodetect*           = 0;
  gfxAutodetectFullscreen* = 1;
  gfxAutodetectWindowed*   = 2;
  gfxSafe*                 = 3;(*!FIXME*)
  gfxNone*                 = 4;(*!FIXME*)

  (* Mouse Callback Flags *)
  mouseFlagMove*       = 0;
  mouseFlagLeftDown*   = 1;
  mouseFlagLeftUp*     = 2;
  mouseFlagRightDown*  = 3;
  mouseFlagRightUp*    = 4;
  mouseFlagMiddleDown* = 5;
  mouseFlagMiddleUp*   = 6;
  mouseFlagMoveZ*      = 7;

  (* Color Conversion *)
  colorconvKeepTrans* = 4000000H;

  (* Draw Sprite Modes *)
  drawSpriteNormal* = 0;
  drawSpriteLit*    = 1;
  drawSpriteTrans*  = 2;

  (* Draw Sprite Flips *)
  drawSpriteNoFlip* = 0;
  drawSpriteHFlip*  = 1;
  drawSpriteVFlip*  = 2;
  drawSpriteVHFlip* = 3;

TYPE
  INT8* = SYSTEM.INT8;
  INT16* = SYSTEM.INT16;

  Bitmap* = RECORD
    w*, h*, clip*, cl*, cr*, ct*, cb*: INTEGER;
    vtable*, writeBank*, readBank*, dat*: SYSTEM.ADDRESS;
    id*: INTEGER;
    extra*: SYSTEM.ADDRESS;
    xOfs*, yOfs*, seg*: INTEGER;
    line*: ARRAY 4000 OF SYSTEM.ADDRESS (*!FIXME*)
  END;

  PBitmap* = POINTER TO Bitmap;

  GfxDriver* = RECORD
    id*: INTEGER;
    name*, desc*, asciiName*: SYSTEM.ADDRESS;
    methods*: ARRAY 23 OF SYSTEM.ADDRESS;
    w*, h*, linear*: INTEGER;
    bankSize*, bankGran*, vidMem*, vidPhysBase*, windowed*: INTEGER
  END;

  PGfxDriver* = POINTER TO GfxDriver;

  Rgb* = RECORD r, g, b: CHAR END;
  PRgb* = POINTER TO Rgb;

  CloseButtonCb* = PROCEDURE;
  UKeyCb* = PROCEDURE(key: INTEGER; VAR scancode: INTEGER): INTEGER;
  ULowKeyCb* = PROCEDURE(scancode: INTEGER);
  MouseCb* = PROCEDURE(flags: SET(*int really*));
  TimerCb* = PROCEDURE;

PROCEDURE -AAIncludeAllegroh0* '#include "Allegro.h0"';

(* VAR *)
PROCEDURE -screen*(): PBitmap
  "((void *)screen)";

(* VAR *)
PROCEDURE -gfxDriver*(): PGfxDriver
  "((void *)gfx_driver)";

PROCEDURE -InstallAllegro*
  (systemId: INTEGER;
  errnoPtr: SYSTEM.ADDRESS;
  atexitPtr: SYSTEM.ADDRESS): INTEGER
  "install_allegro(systemId, &errno, &atexit)";

PROCEDURE -Exit*
  "allegro_exit()";

PROCEDURE -SetCloseButtonCallback*(cb: CloseButtonCb)
  "set_close_button_callback(cb)";

PROCEDURE -SetColorDepth*(depth: INTEGER)
  "set_color_depth(depth)";

PROCEDURE -SetGfxMode*
  (card, w, h, vw, vh: INTEGER): INTEGER
  "set_gfx_mode(card, w, h, vw, vh)";

PROCEDURE -InstallKeyboard*(): INTEGER
  "install_keyboard()";

PROCEDURE -InstallMouse*(): INTEGER
  "install_mouse()";

PROCEDURE -InstallTimer*(): INTEGER
  "install_timer()";

PROCEDURE -SetWindowTitle*(name: ARRAY OF CHAR)
  "set_window_title(name)";

PROCEDURE -GetDesktopResolution*(VAR w, h: INTEGER): INTEGER
  "get_desktop_resolution(w, h)";

PROCEDURE -Rest*(time: INTEGER)
  "rest(time)";

PROCEDURE -USleep*(time: INTEGER) (*Can be removed if Rest is used*)
  "usleep(time)";

PROCEDURE -VSync*
  "vsync()";

PROCEDURE -GetKeyShifts*(VAR ks: SET)
  "*ks = key_shifts";

PROCEDURE -KeyPressed*(): INTEGER
  "keypressed()";

PROCEDURE -ReadKey*(): INTEGER
  "readkey()";

PROCEDURE -UReadKey*(VAR scancode: INTEGER): INTEGER
  "ureadkey(scancode)";

PROCEDURE -SetKeyboardUCallback*(cb: UKeyCb)
  "keyboard_ucallback = cb";

PROCEDURE -SetKeyboardLowlevelCallback*(cb: ULowKeyCb)
  "keyboard_lowlevel_callback = cb";

PROCEDURE -MakeCol32*(r, g, b: INTEGER): INTEGER
  "makecol32(r, g, b)";

PROCEDURE -MakeACol32*(r, g, b, a: INTEGER): INTEGER
  "makeacol32(r, g, b, a)";

PROCEDURE -GetPixel32*(bmp: PBitmap; x, y: INTEGER): INTEGER
  "_getpixel32((BITMAP *)bmp, x, y)";

PROCEDURE -PutPixel32*(bmp: PBitmap; x, y, color: INTEGER)
  "_putpixel32((BITMAP *)bmp, x, y, color)";

PROCEDURE -Line*(bmp: PBitmap; x1, y1, x2, y2, color: INTEGER)
  "line((BITMAP *)bmp, x1, y1, x2, y2, color)";

PROCEDURE -FastLine*(bmp: PBitmap; x1, y1, x2, y2, color: INTEGER)
  "fastline((BITMAP *)bmp, x1, y1, x2, y2, color)";

PROCEDURE -HLine*(bmp: PBitmap; x1, y, x2, color: INTEGER)
  "hline((BITMAP *)bmp, x1, y, x2, color)";

PROCEDURE -VLine*(bmp: PBitmap; x, y1, y2, color: INTEGER)
  "vline((BITMAP *)bmp, x, y1, y2, color)";

PROCEDURE -Rect*(bmp: PBitmap; x1, y1, x2, y2, color: INTEGER)
  "rect((BITMAP *)bmp, x1, y1, x2, y2, color)";

PROCEDURE -RectFill*(bmp: PBitmap; x1, y1, x2, y2, color: INTEGER)
  "rectfill((BITMAP *)bmp, x1, y1, x2, y2, color)";

PROCEDURE -ClearBitmap*(bmp: PBitmap)
  "clear_bitmap((BITMAP *)bmp)";

PROCEDURE -ClearToColor*(bmp: PBitmap; color: INTEGER)
  "clear_to_color((BITMAP *)bmp, color)";

PROCEDURE -Circle*(bmp: PBitmap; x, y, r, color: INTEGER)
  "circle((BITMAP *)bmp, x, y, r, color)";

PROCEDURE -CircleFill*(bmp: PBitmap; x, y, r, color: INTEGER)
  "circlefill((BITMAP *)bmp, x, y, r, color)";

PROCEDURE -Ellipse*(bmp: PBitmap; x, y, rx, ry, color: INTEGER)
  "ellipse((BITMAP *)bmp, x, y, rx, ry, color)";

PROCEDURE -EllipseFill*(bmp: PBitmap; x, y, rx, ry, color: INTEGER)
  "ellipsefill((BITMAP *)bmp, x, y, rx, ry, color)";

PROCEDURE -FloodFill*(bmp: PBitmap; x, y, color: INTEGER)
  "floodfill((BITMAP *)bmp, x, y, color)";

PROCEDURE -GetR32*(color: INTEGER): INTEGER
  "getr32(color)";

PROCEDURE -GetG32*(color: INTEGER): INTEGER
  "getg32(color)";

PROCEDURE -GetB32*(color: INTEGER): INTEGER
  "getb32(color)";

PROCEDURE -GetA32*(color: INTEGER): INTEGER
  "geta32(color)";

(* Bitmaps *)

PROCEDURE -CreateBitmap*(w, h: INTEGER): PBitmap
  "(Allegro_Bitmap *)create_bitmap(w, h)";

PROCEDURE -CreateBitmapEx*(depth, w, h: INTEGER): PBitmap
  "(Allegro_Bitmap *)create_bitmap_ex(depth, w, h)";

PROCEDURE -CreateSubBitmap*(parent: PBitmap; x, y, w, h: INTEGER): PBitmap
  "(Allegro_Bitmap *)create_sub_bitmap((BITMAP *)parent, x, y, w, h)";

PROCEDURE -DestroyBitmap*(bmp: PBitmap)
  "destroy_bitmap((BITMAP *)bmp)";

PROCEDURE -AcquireBitmap*(bmp: PBitmap)
  "acquire_bitmap((BITMAP *)bmp)";

PROCEDURE -ReleaseBitmap*(bmp: PBitmap)
  "release_bitmap((BITMAP *)bmp)";

PROCEDURE -LoadBitmap*(filename: ARRAY OF CHAR; pal: PRgb): PBitmap
  "(Allegro_Bitmap *)load_bitmap(filename, pal)";

PROCEDURE -LoadPngInit*
  "loadpng_init()";

(* Mouse *)

PROCEDURE -MouseOnScreen*(): INTEGER
  "mouse_on_screen()";

PROCEDURE -SetMouseCallback*(cb: MouseCb)
  "mouse_callback = (void *)cb";

PROCEDURE -GetMouseX*(VAR x: INTEGER)
  "*x = mouse_x";

PROCEDURE -GetMouseY*(VAR y: INTEGER)
  "*y = mouse_y";

PROCEDURE -GetMouseZ*(VAR z: INTEGER)
  "*z = mouse_z";

PROCEDURE -GetMouseW*(VAR w: INTEGER)
  "*w = mouse_w";

PROCEDURE -GetMouseB*(VAR b: SET(*int*))
  "*b = mouse_b";

PROCEDURE -GetMousePos*(VAR pos: INTEGER)
  "*pos = mouse_pos";

(* Blitting *)

PROCEDURE -Blit*(src, dest: PBitmap; sx, sy, dx, dy, w, h: INTEGER)
  "blit((BITMAP *)src, (BITMAP *)dest, sx, sy, dx, dy, w, h)";

PROCEDURE -StretchBlit*
  (src, dest: PBitmap; sx, sy, sw, sh, dx, dy, dw, dh: INTEGER)
  "stretch_blit((BITMAP *)src, (BITMAP *)dest, sx, sy, sw, sh, dx, dy, dw, dh)";

PROCEDURE -MaskedBlit*
  (src, dest: PBitmap; sx, sy, dx, dy, w, h: INTEGER)
  "masked_blit((BITMAP *)src, (BITMAP *)dest, sx, sy, dx, dy, w, h)";

PROCEDURE -MaskedStretchBlit*
  (src, dest: PBitmap; sx, sy, sw, sh, dx, dy, dw, dh: INTEGER)
  "masked_stretch_blit((BITMAP *)src, (BITMAP *)dest, sx, sy, sw, sh, dx, dy, dw, dh)";

PROCEDURE -DrawSprite*
  (bmp, sprite: PBitmap; x, y: INTEGER)
  "draw_sprite((BITMAP *)bmp, (BITMAP *)sprite, x, y)";

PROCEDURE -DrawSpriteEx*
  (bmp, sprite: PBitmap; x, y, mode, flip: INTEGER)
  "draw_sprite_ex((BITMAP *)bmp, (BITMAP *)sprite, x, y, mode, flip)";

PROCEDURE -DrawSpriteVFlip*
  (bmp, sprite: PBitmap; x, y: INTEGER)
  "draw_sprite_v_flip((BITMAP *)bmp, (BITMAP *)sprite, x, y)";

PROCEDURE -DrawSpriteHFlip*
  (bmp, sprite: PBitmap; x, y: INTEGER)
  "draw_sprite_h_flip((BITMAP *)bmp, (BITMAP *)sprite, x, y)";

PROCEDURE -DrawSpriteVHFlip*
  (bmp, sprite: PBitmap; x, y: INTEGER)
  "draw_sprite_vh_flip((BITMAP *)bmp, (BITMAP *)sprite, x, y)";

PROCEDURE -DrawTransSprite*
  (bmp, sprite: PBitmap; x, y: INTEGER)
  "draw_trans_sprite((BITMAP *)bmp, (BITMAP *)sprite, x, y)";

PROCEDURE -DrawCharacterEx*
  (bmp, sprite: PBitmap; x, y, color, bg: INTEGER)
  "draw_character_ex((BITMAP *)bmp, (BITMAP *)sprite, x, y, color, bg)";

PROCEDURE -DrawLitSprite*
  (bmp, sprite: PBitmap; x, y, color: INTEGER)
  "draw_lit_sprite((BITMAP *)bmp, (BITMAP *)sprite, x, y, color)";

PROCEDURE -DrawGouraudSprite*
  (bmp, sprite: PBitmap; x, y, c1, c2, c3, c4: INTEGER)
  "draw_gouraud_sprite((BITMAP *)bmp, (BITMAP *)sprite, x, y, c1, c2, c3, c4)";

PROCEDURE -SetColorConversion*(mode: INTEGER)
  "set_color_conversion(mode)";

PROCEDURE -SetAlphaBlender*
  "set_alpha_blender()";

PROCEDURE -SetColorBlender*(r, g, b, a: INTEGER)
  "set_color_blender(r, g, b, a)";

PROCEDURE -SetHueBlender*(r, g, b, a: INTEGER)
  "set_hue_blender(r, g, b, a)";

PROCEDURE -SetLuminanceBlender*(r, g, b, a: INTEGER)
  "set_luminance_blender(r, g, b, a)";

PROCEDURE -SetTransBlender*(r, g, b, a: INTEGER)
  "set_trans_blender(r, g, b, a)";

(* Timer *)

PROCEDURE -InstallInt*
  (cb: TimerCb; speed: INTEGER)
  "install_int((void *)cb, speed)";

(* Atomic *)

PROCEDURE -AtomicZero*()
  "_al_atomic_int = 0";

PROCEDURE -AtomicInc*()
  "_al_atomic_int++";

PROCEDURE -AtomicDec*()
  "_al_atomic_int--";

PROCEDURE -GetAtomic*(): INTEGER
  "_al_atomic_int";

END Allegro.
