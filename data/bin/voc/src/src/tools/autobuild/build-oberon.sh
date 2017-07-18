# Build Oberon
#
# Args
#
# $1 - whether to use sudo
# $2 - build directory
# $3 - CC
# $4 - branch

if test "$1" = "sudo"; then sudo=sudo; else sudo=""; fi

echo ""
echo === build-oberon.sh: \$1="$1", \$2="$2", \$3="$3", \$4="$4", \$sudo="$sudo" ===
echo ""

set -x
cd $2

$sudo git reset --hard    # Clear the staging area
$sudo git clean -dfx      # Remove all untracked files
$sudo git pull            # Update the local repository
$sudo git checkout -f $4  # Switch to requested branch

export CC=$3

if test "$3" = "msc-x86"; then
  cmd /c 'C:\Program Files (x86)\Microsoft Visual C++ Build Tools\vcbuildtools.bat' x86 '&&' cd 'c:\cygwin\home\dave\msc-x86\voc' '&&' make full
else
if test "$3" = "msc-x64"; then
  cmd /c 'C:\Program Files (x86)\Microsoft Visual C++ Build Tools\vcbuildtools.bat' x64 '&&' cd 'c:\cygwin\home\dave\msc-x64\voc' '&&' make full
else
  $sudo make full
fi
fi
