#!/bin/bash
suf="out"

hipcc -std=c++17 --amdgpu-target=gfx90a \
-I ./include \
-I ./library/include \
$1 \
-o $1$suf \
./library/src/utility/*.cpp \
2>&1 | tee log.txt