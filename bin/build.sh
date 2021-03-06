#!/usr/bin/env bash

set -e

if [[ "$0" =~ ^/ ]] ; then
  this_file="$0"
else
  this_file="$(pwd)/$0"
fi
this_dir="$(dirname "$this_file")"
build_dir_vim=
. "${this_dir}/common.sh"

VERBOSE=1 cmake --build "$build_dir_vim"
