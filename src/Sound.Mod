MODULE Sound;
IMPORT Out, G := Graph, Al := Allegro5, SYSTEM, Platform;

TYPE
  Stream* = POINTER TO StreamDesc;
  StreamDesc* = RECORD
    str: Al.ADRINT;
  END;

VAR
  Done*: BOOLEAN;

  stream: Stream;

PROCEDURE Error(s: ARRAY OF CHAR);
BEGIN Out.String(s); Out.Ln
END Error;

PROCEDURE Sound*(freq: INTEGER);
BEGIN

END Sound;

PROCEDURE NoSound*;
BEGIN

END NoSound;

PROCEDURE Init*;
VAR ok: BOOLEAN;
BEGIN
  Done := FALSE;
  IF ~G.initialized THEN G.Init END;
  IF G.initialized THEN
    ok := TRUE;
    IF ~Al.install_audio() THEN
      Error('Could not install audio.'); ok := FALSE
    END;
    IF ok & ~Al.init_acodec_addon() THEN
      Error('Could not init acodec addon.'); ok := FALSE
    END;
    IF ok & ~Al.reserve_samples(16(*!FIXME*)) THEN
      Error('Could not reserve audio samples.'); ok := FALSE
    END;
    IF ok THEN
      NEW(stream);
      stream.str := Al.create_audio_stream(8, 1024(*!FIXME*), 22050,
        Al.audioDepthUint8, Al.channelConf1);
      IF stream.str # 0 THEN
        Done := TRUE
      END
    END
  END
END Init;

PROCEDURE Close*;
BEGIN
  Al.destroy_audio_stream(stream.str);
END Close;

BEGIN
  Done := FALSE
END Sound.
