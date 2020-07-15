#!/usr/bin/env bash
set -eu

git submodule update --init --recursive


this_file="$(type -P "${BASH_SOURCE[0]}")"
if ! [ -e "$this_file" ] ; then
  echo "Failed to resolve file."
  exit 1
fi
if ! [[ "$this_file" =~ ^/ ]] ; then
  this_file="$(pwd)/$this_file"
fi
while [ -h "$this_file" ] ; do
    ls_res="$(ls -ld "$this_file")"
    link_target=$(expr "$ls_res" : '.*-> \(.*\)$')
    if [[ "$link_target" =~ ^/ ]] ; then
      this_file="$link_target"
    else
      this_file="$(dirname "$this_file")/$link_target"
    fi
done
this_dir="$(dirname "$this_file")"

"${this_dir}/configure.sh"
