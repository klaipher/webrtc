#!/bin/sh
# Guarded Apple Clang workaround for abseil 20260817.0 (see NANOGRAM-CHANGES.md).
# Copies the pristine abseil tree to <out> (the submodule is never edited) and
# disables ABSL_ATTRIBUTE_LIFETIME_BOUND there. Only run it if an Apple Clang
# build of third_party/abseil-cpp fails on lifetimebound; then pass
# -DTG_OWT_ABSEIL_DIR=<out> to CMake (or point the consumer's abseil path at it).
set -eu
src=${1:?usage: apply_abseil_workaround.sh <abseil-src> <out-dir>}
out=${2:?usage: apply_abseil_workaround.sh <abseil-src> <out-dir>}
here=$(cd "$(dirname "$0")/.." && pwd)
rm -rf "$out"
mkdir -p "$out"
(cd "$src" && tar --exclude=.git -cf - .) | (cd "$out" && tar -xf -)
(cd "$out" && patch -p1 < "$here/patches/abseil-20260817-disable-lifetimebound.patch")
