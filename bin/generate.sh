#!/usr/bin/env bash
set -eu

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

src_dir="${this_dir}/.."

declare -a list_of_files=()
list_of_files+=("${src_dir}/CMakeLists.txt.tmpl")
list_of_files+=("${src_dir}/src/app/CMakeLists.txt.tmpl")
list_of_files+=("${src_dir}/src/app/main.cc.tmpl")
list_of_files+=("${src_dir}/src/lib/CMakeLists.txt.tmpl")
list_of_files+=("${src_dir}/src/lib/error.cc.tmpl")
list_of_files+=("${src_dir}/src/lib/error.h.tmpl")
list_of_files+=("${src_dir}/src/lib/logging/CMakeLists.txt.tmpl")
list_of_files+=("${src_dir}/src/lib/logging/logging.cc.tmpl")
list_of_files+=("${src_dir}/src/lib/logging/logging.h.tmpl")
list_of_files+=("${src_dir}/src/test/CmakeLists.txt.tmpl")
list_of_files+=("${src_dir}/src/test/error_tests.cc.tmpl")

project_name=
while [ "$#" -gt 0 ] ; do
  key="$1"
  case $key in
      --project-name)
      project_name="$2"
      shift ; shift
      ;;
  esac
done

show_help() {
  printf "Usage:\n\
  %s --project-name <project_name>\n" "$0"
}

if [ -z "$project_name" ] ; then
  show_help
  exit 1
fi

generate_file() {
  local tmpl_file="$1"
  local tmpl_dir=
  local tmpl_name=
  local generated_file=
  tmpl_dir="$(dirname "$tmpl_file")"
  tmpl_name="$(basename "$tmpl_file" ".tmpl")"
  generated_file="${tmpl_dir}/${tmpl_name}"
  >"$generated_file" sed -E $'s/\x1eproject_name\x1e/'"${project_name}/" "$tmpl_file"
  rm "$tmpl_file"
}

for ff in "${list_of_files[@]}" ; do
  generate_file "$ff"
done
