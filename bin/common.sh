#!/usr/bin/env bash
name="${BASH_SOURCE[0]}"
if [[ "$name" =~ ^/ ]] ; then
  this_file="$name"
else
  this_file="$(pwd)/$name"
fi
this_dir="$(dirname "$this_file")"

export build_dir_vim=build-for-vim
export build_dir_path="${this_dir}/../${build_dir_vim}"
test -d "$build_dir_path" || mkdir -p "$_"
