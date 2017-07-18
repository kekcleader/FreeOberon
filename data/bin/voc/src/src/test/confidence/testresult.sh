#!/bin/sh
# '.' this from indiviual test.sh files
if diff -b expected result
then printf "PASSED: $PWD\n\n"
else printf "FAILED: $PWD\n\n"; exit 1
fi

# Compare generated code
if [ -f new.asm ]
#then sed -n '/^ *[0-9]\+ \([0-9a-f]\{4\}\|    \) [0-9A-F]\{2\}[0-9A-F ]\{6\}/s/^ *[0-9]\+ ....//p' new.asm>new.$FLAVOUR.$BRANCH.s
then sed -n '/^ *[0-9]\+ \([0-9a-f]\{4\}\|    \) [0-9A-F]\{2\}[0-9A-F ]\{6\}/s/^ *[0-9]\+ ....//p' new.asm | sed 's/_m.[0-9]\+/_m.xxx/' >new.$FLAVOUR.$BRANCH.s

  if [ -f old.$FLAVOUR.$BRANCH.s -a old.$FLAVOUR.$BRANCH.s -nt ../planned-binary-change ]
  then
    if diff -b old.$FLAVOUR.$BRANCH.s new.$FLAVOUR.$BRANCH.s
    then echo "--- Generated code unchanged ---"
    else echo "--- Generated code changed ---"
    fi
  else
    cp new.$FLAVOUR.$BRANCH.s old.$FLAVOUR.$BRANCH.s
    echo "--- Generated code snapped ---"
  fi

fi
