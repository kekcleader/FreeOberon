# Source change tests.
#
# Compares compiler source files against the appropriate bootstrap source.
# The voc compiler version comment line is skipped.
#
# Parameters
#
#   $1 - bootstrap directory
#
# Assumptions
#
#   The current directory is the build directory

changes="0"
find "$1" -type f -print0 | while IFS= read -r -d '' f; do
  fn=$(basename "$f")
  egrep -v -f ../../src/tools/make/ignore "$f"  >$fn.old
  egrep -v -f ../../src/tools/make/ignore $fn >$fn.new
  if ! diff -U 2 -b $fn.old $fn.new >$fn.diff; then
    echo ""
    echo ""
    cat $fn.diff
    changes=1;
  fi
  rm -f $fn.old $fn.new $fn.diff
done
echo ""
if [ "$changes" = "0" ]; then
  echo "--- Generated c source files match bootstrap ---"
else
  echo "--- Generated c source files differ from bootstrap ---"
fi
echo ""
