MODULE [foreign] Allegro5;
IMPORT SYSTEM;

CONST
  (** Values of al_set_new_display_flags *)
  windowed*                = 0;
  fullscreen*              = 1;
  opengl*                  = 2;
  direct3dInternal*        = 3;
  resizable*               = 4;
  frameless*               = 5;
  generateExposeEvents*    = 6;
  opengl30*                = 7;
  openglForwardCompatible* = 8;
  fullscreenWindow*        = 9;
  minimized*               = 10;
  programmablePipeline*    = 11;
  gtkToplevelInternal*     = 12;
  maximized*               = 13;
  openglEsProfile*         = 14;

  (** Values of parameter importance in al_set_new_display_option *)
  dontcare* = 0;
  require*  = 1;
  suggest*  = 2;

  (** Bitmap Flags *)
  memoryBitmap*         = 0;
  keepBitmapFormat*     = 1;
  forceLocking*         = 2;
  noPreserveTexture*    = 3;
  alphaTest*            = 4;
  internalOpengl*       = 5;
  minLinear*            = 6;
  magLinear*            = 7;
  mipmap*               = 8;
  noPremultipliedAlpha* = 9;
  videoBitmap*          = 10;
  convertBitmap*        = 12;

  (** Values of parameter option in al_set_new_display_option *)
  redSize*               = 0;
  greenSize*             = 1;
  blueSize*              = 2;
  alphaSize*             = 3;
  redShift*              = 4;
  greenShift*            = 5;
  blueShift*             = 6;
  alphaShift*            = 7;
  accRedSize*            = 8;
  accGreenSize*          = 9;
  accBlueSize*           = 10;
  accAlphaSize*          = 11;
  stereo*                = 12;
  auxBuffers*            = 13;
  colorSize*             = 14;
  depthSize*             = 15;
  stencilSize*           = 16;
  sampleBuffers*         = 17;
  samples*               = 18;
  renderMethod*          = 19;
  floatColor*            = 20;
  floatDepth*            = 21;
  singleBuffer*          = 22;
  swapMethod*            = 23;
  compatibleDisplay*     = 24;
  updateDisplayRegion*   = 25;
  vsync*                 = 26;
  maxBitmapSize*         = 27;
  supportNpotBitmap*     = 28;
  canDrawIntoBitmap*     = 29;
  supportSeparateAlpha*  = 30;
  autoConvertBitmaps*    = 31;
  supportedOrientations* = 32;
  openglMajorVersion*    = 33;
  openglMinorVersion*    = 34;
  displayOptionsCount*   = 35;

  (** Values of Event.type *)
  eventJoystickAxis*          =  1;
  eventJoystickButtonDown*    =  2;
  eventJoystickButtonUp*      =  3;
  eventJoystickConfiguration* =  4;

  eventKeyDown*               = 10;
  eventKeyChar*               = 11;
  eventKeyUp*                 = 12;

  eventMouseAxes*             = 20;
  eventMouseButtonDown*       = 21;
  eventMouseButtonUp*         = 22;
  eventMouseEnterDisplay*     = 23;
  eventMouseLeaveDisplay*     = 24;
  eventMouseWarped*           = 25;

  eventTimer*                 = 30;

  eventDisplayExpose*         = 40;
  eventDisplayResize*         = 41;
  eventDisplayClose*          = 42;
  eventDisplayLost*           = 43;
  eventDisplayFound*          = 44;
  eventDisplaySwitchIn*       = 45;
  eventDisplaySwitchOut*      = 46;
  eventDisplayOrientation*    = 47;
  eventDisplayHaltDrawing*    = 48;
  eventDisplayResumeDrawing*  = 49;

  eventTouchBegin*            = 50;
  eventTouchEnd*              = 51;
  eventTouchMove*             = 52;
  eventTouchCancel*           = 53;

  eventDisplayConnected*      = 60;
  eventDisplayDisconnected*   = 61;

  (** Flip flags for al_draw_bitmap *)
  flipHorizontal* = 1;
  flipVertical* = 2;

  (** Key codes *)
  keyA* = 1;
  keyB* = 2;
  keyC* = 3;
  keyD* = 4;
  keyE* = 5;
  keyF* = 6;
  keyG* = 7;
  keyH* = 8;
  keyI* = 9;
  keyJ* = 10;
  keyK* = 11;
  keyL* = 12;
  keyM* = 13;
  keyN* = 14;
  keyO* = 15;
  keyP* = 16;
  keyQ* = 17;
  keyR* = 18;
  keyS* = 19;
  keyT* = 20;
  keyU* = 21;
  keyV* = 22;
  keyW* = 23;
  keyX* = 24;
  keyY* = 25;
  keyZ* = 26;

  key0* = 27;
  key1* = 28;
  key2* = 29;
  key3* = 30;
  key4* = 31;
  key5* = 32;
  key6* = 33;
  key7* = 34;
  key8* = 35;
  key9* = 36;

  keyPad0* = 37;
  keyPad1* = 38;
  keyPad2* = 39;
  keyPad3* = 40;
  keyPad4* = 41;
  keyPad5* = 42;
  keyPad6* = 43;
  keyPad7* = 44;
  keyPad8* = 45;
  keyPad9* = 46;

  keyF1*  = 47;
  keyF2*  = 48;
  keyF3*  = 49;
  keyF4*  = 50;
  keyF5*  = 51;
  keyF6*  = 52;
  keyF7*  = 53;
  keyF8*  = 54;
  keyF9*  = 55;
  keyF10* = 56;
  keyF11* = 57;
  keyF12* = 58;

  keyEscape*      = 59;
  keyTilde*       = 60;
  keyMinus*       = 61;
  keyEquals*      = 62;
  keyBackspace*   = 63;
  keyTab*         = 64;
  keyOpenbrace*   = 65;
  keyClosebrace*  = 66;
  keyEnter*       = 67;
  keySemicolon*   = 68;
  keyQuote*       = 69;
  keyBackslash*   = 70;
  keyBackslash2*  = 71;
  keyComma*       = 72;
  keyFullstop*    = 73;
  keySlash*       = 74;
  keySpace*       = 75;

  keyInsert*      = 76;
  keyDelete*      = 77;
  keyHome*        = 78;
  keyEnd*         = 79;
  keyPgup*        = 80;
  keyPgdn*        = 81;
  keyLeft*        = 82;
  keyRight*       = 83;
  keyUp*          = 84;
  keyDown*        = 85;

  keyPadSlash*    = 86;
  keyPadAsterisk* = 87;
  keyPadMinus*    = 88;
  keyPadPlus*     = 89;
  keyPadDelete*   = 90;
  keyPadEnter*    = 91;

  keyPrintscreen* = 92;
  keyPause*       = 93;

  keyAbntC1*      = 94;
  keyYen*         = 95;
  keyKana*        = 96;
  keyConvert*     = 97;
  keyNoconvert*   = 98;
  keyAt*          = 99;
  keyCircumflex*  = 100;
  keyColon2*      = 101;
  keyKanji*       = 102;

  keyPadEquals*   = 103;
  keyBackquote*   = 104;
  keySemicolon2*  = 105;
  keyCommand*     = 106;

  keyBack*        = 107;
  keyVolumeUp*    = 108;
  keyVolumeDown*  = 109;

  keySearch*      = 110;
  keyDpadCenter*  = 111;
  keyButtonX*     = 112;
  keyButtonY*     = 113;
  keyDpadUp*      = 114;
  keyDpadDown*    = 115;
  keyDpadLeft*    = 116;
  keyDpadRight*   = 117;
  keySelect*      = 118;
  keyStart*       = 119;
  keyButtonL1*    = 120;
  keyButtonR1*    = 121;
  keyButtonL2*    = 122;
  keyButtonR2*    = 123;
  keyButtonA*     = 124;
  keyButtonB*     = 125;
  keyThumbl*      = 126;
  keyThumbr*      = 127;

  keyUnknown*     = 128;

  keyModifiers*   = 215;

  keyLshift*      = 215;
  keyRshift*      = 216;
  keyLctrl*       = 217;
  keyRctrl*       = 218;
  keyAlt*         = 219;
  keyAltgr*       = 220;
  keyLwin*        = 221;
  keyRwin*        = 222;
  keyMenu*        = 223;
  keyScrolllock*  = 224;
  keyNumlock*     = 225;
  keyCapslock*    = 226;

  keyMax*         = 227;

  keymodShift*      = 0;
  keymodCtrl*       = 1;
  keymodAlt*        = 2;
  keymodLwin*       = 3;
  keymodRwin*       = 4;
  keymodMenu*       = 5;
  keymodAltgr*      = 6;
  keymodCommand*    = 7;
  keymodScrolllock* = 8;
  keymodNumlock*    = 9;
  keymodCapslock*   = 10;
  keymodInaltseq*   = 11;
  keymodAccent1*    = 12;
  keymodAccent2*    = 13;
  keymodAccent3*    = 14;
  keymodAccent4*    = 15;

  (* Other *)
  intMax* = 2147483647;

TYPE
  ADRINT* = SYSTEM.ADRINT;
  SHORTCHAR* = SYSTEM.CHAR8;
  SHORTINT* = SYSTEM.INT16;
  LONGREAL* = SYSTEM.REAL64;
  LONGINT* = SYSTEM.INT64;

  Color* = RECORD [1]
    r*, g*, b*, a*: REAL
  END;

  Transform* = RECORD [1]
    m*: ARRAY 4, 4 OF REAL
  END;

  LockedRegion* = POINTER [1] TO LockedRegionDesc;
  LockedRegionDesc* = RECORD [1]
    data*: ADRINT;
    format*: INTEGER;
    pitch*: INTEGER;
    pixelSize*: INTEGER
  END;

  Display* = POINTER [1] TO RECORD [1] END;
  Bitmap* = POINTER [1] TO RECORD [1] END;
  EventQueue* = POINTER [1] TO RECORD [1] END;
  Timer* = POINTER [1] TO RECORD [1] END;
  EventSource* = POINTER [1] TO RECORD [1] END;

  DisplayEvent* = RECORD [1]
    type*: INTEGER;
    source*: Display;
    timestamp*: LONGREAL;
    x*, y*: INTEGER;
    width*, height*: INTEGER;
    orientation*: INTEGER
  END;

  KeyboardEvent* = RECORD [1]
    type*: INTEGER;
    source*: ADRINT;
    timestamp*: LONGREAL;
    display*: Display;
    keycode*: INTEGER;
    unichar*: INTEGER;
    modifiers*: SET;
    repeat*: BOOLEAN
  END;

  MouseEvent* = RECORD [1]
    type*: INTEGER;
    source*: ADRINT;
    timestamp*: LONGREAL;
    display*: Display;
    x*, y*, z*, w*: INTEGER;
    dx*, dy*, dz*, dw*: INTEGER;
    button*: INTEGER;
    pressure*: REAL
  END;

  TouchEvent* = RECORD [1]
    type*: INTEGER;
    source*: ADRINT;
    timestamp*: LONGREAL;
    display*: Display;
    id*: INTEGER;
    x*, y*: REAL;
    dx*, dy*: REAL;
    primary*: BOOLEAN
  END;

  TimerEvent* = RECORD [1]
    type*: INTEGER;
    source*: ADRINT;
    timestamp*: LONGREAL;
    count*: LONGINT;
    error*: LONGREAL
  END;

  Event* = RECORD [1]
    type*: INTEGER;
    source*: ADRINT;
    timestamp*: LONGREAL;
    pad: ARRAY 1000 OF BYTE
  END;

  PEvent* = POINTER TO Event;
  PTimerEvent* = POINTER [1] TO TimerEvent;
  PKeyboardEvent* = POINTER [1] TO KeyboardEvent;
  PMouseEvent* = POINTER [1] TO MouseEvent;
  PDisplayEvent* = POINTER [1] TO DisplayEvent;

  MonitorInfo* = RECORD [1]
    x1*, y1*, x2*, y2*: INTEGER
  END;

PROCEDURE get_allegro_version* ["al_get_allegro_version"] (): INTEGER;
PROCEDURE install_system* ["al_install_system"] (version, atexit: ADRINT): BOOLEAN;
PROCEDURE uninstall_system* ["al_uninstall_system"] ();
PROCEDURE install_keyboard* ["al_install_keyboard"] (): BOOLEAN;
PROCEDURE install_mouse* ["al_install_mouse"] (): BOOLEAN;
PROCEDURE create_timer* ["al_create_timer"] (period: LONGREAL): Timer;
PROCEDURE get_keyboard_event_source* ["al_get_keyboard_event_source"] (): EventSource;
PROCEDURE get_mouse_event_source* ["al_get_mouse_event_source"] (): EventSource;
PROCEDURE get_display_event_source* ["al_get_display_event_source"] (display: Display): EventSource;
PROCEDURE get_timer_event_source* ["al_get_timer_event_source"] (timer: Timer): EventSource;
PROCEDURE start_timer* ["al_start_timer"] (timer: Timer);
PROCEDURE register_event_source* ["al_register_event_source"] (queue: EventQueue; source: EventSource);
PROCEDURE wait_for_event* ["al_wait_for_event"] (queue: EventQueue; VAR event: Event);
PROCEDURE clear_to_color* ["al_clear_to_color"] (color: Color);
PROCEDURE destroy_timer* ["al_destroy_timer"] (timer: Timer);
PROCEDURE destroy_event_queue* ["al_destroy_event_queue"] (queue: EventQueue);

PROCEDURE create_event_queue* ["al_create_event_queue"] (): EventQueue;
PROCEDURE is_event_queue_empty* ["al_is_event_queue_empty"] (queue: EventQueue): BOOLEAN;

PROCEDURE set_new_display_flags* ["al_set_new_display_flags"] (flags: SET);
PROCEDURE get_display_flags* ["al_get_display_flags"] (display: Display): SET;
PROCEDURE set_display_flag* ["al_set_display_flag"] (display: Display; flag: INTEGER; on: BOOLEAN): BOOLEAN;
PROCEDURE toggle_display_flag* ["al_toggle_display_flag"] (display: Display; flag: INTEGER; on: BOOLEAN);
PROCEDURE set_new_display_option* ["al_set_new_display_option"] (option, value, importance: INTEGER);
PROCEDURE get_display_option* ["al_get_display_option"] (display: Display; option: INTEGER): INTEGER;
PROCEDURE set_display_option* ["al_set_display_option"] (display: Display; option, value: INTEGER);
PROCEDURE set_new_window_position* ["al_set_new_window_position"] (x, y: INTEGER);
PROCEDURE set_window_title* ["al_set_window_title"] (display: Display; title: ARRAY OF SHORTCHAR);
PROCEDURE set_new_window_title* ["al_set_new_window_title"] (title: ARRAY OF SHORTCHAR);
PROCEDURE create_display* ["al_create_display"] (w, h: INTEGER): Display;
PROCEDURE get_current_display* ["al_get_current_display"] (): Display;
PROCEDURE resize_display* ["al_resize_display"] (display: Display; width, height: INTEGER): BOOLEAN;
PROCEDURE set_window_position* ["al_set_window_position"] (display: Display; x, y: INTEGER);
PROCEDURE flip_display* ["al_flip_display"] ();
PROCEDURE acknowledge_resize* ["al_acknowledge_resize"] (display: Display);
PROCEDURE get_display_width* ["al_get_display_width"] (display: Display): INTEGER;
PROCEDURE get_display_height* ["al_get_display_height"] (display: Display): INTEGER;
PROCEDURE destroy_display* ["al_destroy_display"] (display: Display);
PROCEDURE set_display_icon* ["al_set_display_icon"] (display: Display; icon: Bitmap);
PROCEDURE set_display_icons* ["al_set_display_icons"] (display: Display; numIcons: INTEGER; icons: ARRAY OF Bitmap);

PROCEDURE create_bitmap* ["al_create_bitmap"] (w, h: INTEGER): Bitmap;
PROCEDURE destroy_bitmap* ["al_destroy_bitmap"] (bmp: Bitmap);
PROCEDURE clone_bitmap* ["al_clone_bitmap"] (bmp: Bitmap): Bitmap;
PROCEDURE load_bitmap* ["al_load_bitmap"] (filename: ARRAY OF SHORTCHAR): Bitmap;
PROCEDURE load_bitmap_flags* ["al_load_bitmap_flags"] (filename: ARRAY OF SHORTCHAR; flags: SET): Bitmap;
PROCEDURE save_bitmap* ["al_save_bitmap"] (filename: ARRAY OF SHORTCHAR; VAR bitmap: Bitmap): BOOLEAN;
PROCEDURE get_bitmap_flags* ["al_get_bitmap_flags"] (bmp: Bitmap): SET;
PROCEDURE get_bitmap_format* ["al_get_bitmap_format"] (bmp: Bitmap): INTEGER;
PROCEDURE get_bitmap_width* ["al_get_bitmap_width"] (bmp: Bitmap): INTEGER;
PROCEDURE get_bitmap_height* ["al_get_bitmap_height"] (bmp: Bitmap): INTEGER;
PROCEDURE hold_bitmap_drawing* ["al_hold_bitmap_drawing"] (hold: BOOLEAN);
PROCEDURE is_bitmap_drawing_held* ["al_is_bitmap_drawing_held"] (): BOOLEAN;

PROCEDURE create_sub_bitmap* ["al_create_sub_bitmap"] (parent: Bitmap; x, y, w, h: INTEGER): Bitmap;
PROCEDURE is_sub_bitmap* ["al_is_sub_bitmap"] (bmp: Bitmap): BOOLEAN;
PROCEDURE get_parent_bitmap* ["al_get_parent_bitmap"] (bmp: Bitmap): Bitmap;
PROCEDURE get_bitmap_x* ["al_get_bitmap_x"] (bmp: Bitmap): INTEGER;
PROCEDURE get_bitmap_y* ["al_get_bitmap_y"] (bmp: Bitmap): INTEGER;
PROCEDURE reparent_bitmap* ["al_reparent_bitmap"] (bmp, parent: Bitmap; x, y, w, h: INTEGER);

PROCEDURE lock_bitmap* ["al_lock_bitmap"] (bmp: Bitmap; format, flags: INTEGER): LockedRegion;
PROCEDURE lock_bitmap_region* ["al_lock_bitmap_region"] (bmp: Bitmap; x, y, w, h, format, flags: INTEGER): LockedRegion;
PROCEDURE is_bitmap_locked* ["al_is_bitmap_locked"] (bmp: Bitmap): BOOLEAN;
PROCEDURE unlock_bitmap* ["al_unlock_bitmap"] (bmp: Bitmap);

PROCEDURE convert_bitmap* ["al_convert_bitmap"] (bmp: Bitmap);
PROCEDURE convert_memory_bitmaps* ["al_convert_memory_bitmaps"];
PROCEDURE is_compatible_bitmap* ["al_is_compatible_bitmap"] (bmp: Bitmap): BOOLEAN;

PROCEDURE set_new_bitmap_flags* ["al_set_new_bitmap_flags"] (flags: SET);
PROCEDURE add_new_bitmap_flag* ["al_add_new_bitmap_flag"] (flags: SET);
PROCEDURE get_new_bitmap_flags* ["al_get_new_bitmap_flags"] (): SET;
PROCEDURE set_new_bitmap_format* ["al_set_new_bitmap_format"] (format: INTEGER);
PROCEDURE get_new_bitmap_format* ["al_get_new_bitmap_format"] (): INTEGER;

PROCEDURE draw_bitmap* ["al_draw_bitmap"] (bmp: Bitmap; dx, dy: REAL; flip: SET);
PROCEDURE draw_tinted_bitmap* ["al_draw_tinted_bitmap"] (bmp: Bitmap; tint: Color; dx, dy: REAL; flip: SET);
PROCEDURE draw_bitmap_region* ["al_draw_bitmap_region"] (bmp: Bitmap; sx, sy, sw, sh, dx, dy: REAL; flip: SET);
PROCEDURE draw_tinted_bitmap_region* ["al_draw_tinted_bitmap_region"] (bmp: Bitmap; tint: Color; sx, sy, sw, sh, dx, dy: REAL; flip: SET);
PROCEDURE draw_pixel* ["al_draw_pixel"] (x, y: REAL; color: Color);
PROCEDURE draw_rotated_bitmap* ["al_draw_rotated_bitmap"] (bmp: Bitmap; cx, cy, dx, dy, angle: REAL; flip: SET);
PROCEDURE draw_tinted_rotated_bitmap* ["al_draw_tinted_rotated_bitmap"] (bmp: Bitmap; tint: Color; cx, cy, dx, dy, angle: REAL; flip: SET);
PROCEDURE draw_scaled_rotated_bitmap* ["al_draw_scaled_rotated_bitmap"] (bmp: Bitmap; cx, cy, dx, dy, xScale, yScale, angle: REAL; flip: SET);
PROCEDURE draw_tinted_scaled_rotated_bitmap* ["al_draw_tinted_scaled_rotated_bitmap"] (bmp: Bitmap; tint: Color; cx, cy, dx, dy, xScale, yScale, angle: REAL; flip: SET);
PROCEDURE draw_t_s_r_b_region* ["al_draw_tinted_scaled_rotated_bitmap_region"] (bmp: Bitmap; sx, sy, sw, sh: REAL; tint: Color; cx, cy, dx, dy, xScale, yScale, angle: REAL; flip: SET);
PROCEDURE draw_scaled_bitmap* ["al_draw_scaled_bitmap"] (bmp: Bitmap; sx, sy, sw, sh, dx, dy, dw, dh: REAL; flip: SET);
PROCEDURE draw_tinted_scaled_bitmap* ["al_draw_tinted_scaled_bitmap"] (bmp: Bitmap; tint: Color; sx, sy, sw, sh, dx, dy, dw, dh: REAL; flip: SET);

PROCEDURE set_target_bitmap* ["al_set_target_bitmap"] (bmp: Bitmap);
PROCEDURE get_target_bitmap* ["al_get_target_bitmap"] (): Bitmap;
PROCEDURE set_target_backbuffer* ["al_set_target_backbuffer"] (display: Display);
PROCEDURE put_pixel* ["al_put_pixel"] (x, y: INTEGER; c: Color);
PROCEDURE put_blended_pixel* ["al_put_blended_pixel"] (x, y: INTEGER; c: Color);

PROCEDURE init_primitives_addon* ["al_init_primitives_addon"] (): BOOLEAN;
PROCEDURE init_image_addon* ["al_init_image_addon"] (): BOOLEAN;
PROCEDURE init_audio_addon* ["al_init_audio_addon"] (): BOOLEAN;
PROCEDURE init_acodec_addon* ["al_init_acodec_addon"] (): BOOLEAN;
PROCEDURE init_font_addon* ["al_init_font_addon"] (): BOOLEAN;
PROCEDURE init_native_dialog_addon* ["al_init_native_dialog_addon"] (): BOOLEAN;

PROCEDURE draw_line* ["al_draw_line"] (x1, y1, x2, y2: REAL; color: Color; thickness: REAL);
PROCEDURE draw_triangle* ["al_draw_triangle"] (x1, y1, x2, y2, x3, y3: REAL; color: Color; thickness: REAL);
PROCEDURE draw_rectangle* ["al_draw_rectangle"] (x1, y1, x2, y2: REAL; color: Color; thickness: REAL);
PROCEDURE draw_filled_rectangle* ["al_draw_filled_rectangle"] (x1, y1, x2, y2: REAL; color: Color);
PROCEDURE draw_rounded_rectangle* ["al_draw_rounded_rectangle"] (x1, y1, x2, y2, rx, ry: REAL; color: Color; thickness: REAL);
PROCEDURE draw_filled_rounded_rectangle* ["al_draw_filled_rounded_rectangle"] (x1, y1, x2, y2, rx, ry: REAL; color: Color);
PROCEDURE draw_circle* ["al_draw_circle"] (cx, cy, r: REAL; color: Color; thickness: REAL);
PROCEDURE draw_filled_circle* ["al_draw_filled_circle"] (cx, cy, r: REAL; color: Color);
PROCEDURE draw_ellipse* ["al_draw_ellipse"] (cx, cy, rx, ry: REAL; color: Color; thickness: REAL);
PROCEDURE draw_filled_ellipse* ["al_draw_filled_ellipse"] (cx, cy, rx, ry: REAL; color: Color);
PROCEDURE draw_polyline* ["al_draw_polyline"] (vertices: ARRAY OF REAL; vertexCount, joinStyle, capStyle: INTEGER; color: Color; thickness, miterLimit: REAL);
PROCEDURE draw_polygon* ["al_draw_polygon"] (vertices: ARRAY OF REAL; vertexCount, joinStyle: INTEGER; color: Color; thickness, miterLimit: REAL);
PROCEDURE draw_filled_polygon* ["al_draw_filled_polygon"] (vertices: ARRAY OF REAL; vertexCount: INTEGER; color: Color);
PROCEDURE draw_filled_polygon_with_holes* ["al_draw_filled_polygon_with_holes"] (vertices: ARRAY OF REAL; vertexCounts: ARRAY OF INTEGER; color: Color);

PROCEDURE get_monitor_info* ["al_get_monitor_info"] (adapter: INTEGER; VAR info: MonitorInfo): BOOLEAN;

PROCEDURE rest* ["al_rest"] (seconds: LONGREAL);

PROCEDURE identity_transform* ["al_identity_transform"] (VAR trans: Transform);
PROCEDURE build_transform* ["al_build_transform"] (VAR trans: Transform; x, y, sx, sy, theta: REAL);
PROCEDURE use_transform* ["al_use_transform"] (VAR trans: Transform);

PROCEDURE get_clipboard_text* ["al_get_clipboard_text"] (display: Display): ADRINT;
PROCEDURE set_clipboard_text* ["al_set_clipboard_text"] (display: Display; text: ADRINT): BOOLEAN;
PROCEDURE clipboard_has_text* ["al_clipboard_has_text"] (display: Display): BOOLEAN;

END Allegro5.
