# addlibrary - shell script to install/uninstall oberon libraries
#
# $1 - "install" or "uninstall"
# $2 - location containing .so's
# $3 - oberon name


if ! which ldconfig >/dev/null 2>&1; then exit 0; fi

if test -d /etc/ld.so.conf.d; then

  # Linux-like system
  # Need to update the ldconfig configuration in the /etc/ld.so.conf.d dir.
  if test "$1" = "install"; then
    echo $2>/etc/ld.so.conf.d/lib$3.conf
  else
    rm -f /etc/ld.so.conf.d/lib$3.conf
  fi
  ldconfig

else

  # BSD-like system
  # Just run ldconfig -m to update the cache. It'll add-to/update/reove-from
  # the cache appropraitely for whether they are present opt not.
  ldconfig -m "$2"

fi
