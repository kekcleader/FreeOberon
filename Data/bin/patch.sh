#!/bin/bash
### This script adds a code snippet to the compiled main C file.
### The snippet is required for Allegro5 required on macOS.

TARGET_FILE="$1"
TEMP_FILE="temp_${TARGET_FILE}"

if [[ ! -f "$TARGET_FILE" ]]; then
    echo "File $TARGET_FILE not found!"
    exit 1
fi

PATTERN="\/\*={76}\*\/"

awk -v insertfile="/dev/stdin" '
{
    print
    if ($0 ~ /\/\*={76}\*\//) {
        while ((getline line < insertfile) > 0) {
            print line
        }
        close(insertfile)
    }
}' "$TARGET_FILE" > "$TEMP_FILE" <<'EOF'
extern INTEGER SYSTEM_argc;
extern void *SYSTEM_argv;
#undef main
#define main(__argc, __argv) _main (void *stktop); \
  int _al_mangled_main (__argc, __argv) { \
    SYSTEM_argc = argc; SYSTEM_argv = argv; return _main(&argv); } \
  int __attribute__ ((noinline)) _main (void *stktop)
EOF

mv "$TEMP_FILE" "$TARGET_FILE"
