git log --decorate > CHANGES.md
sed -i  's/@/[at]/g' CHANGES.md
