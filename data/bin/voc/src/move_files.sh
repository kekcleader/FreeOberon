#!/bin/bash
rm -rf ../bin ../C ../lib
mv install/bin ../bin
mv install/C ../C
mkdir ../lib
mv install/lib/libvoc-OC.a ../lib
mv install/lib/libvoc-OC.so ../lib
rm -rf install
rm -rf build/*
rm voc.exe
