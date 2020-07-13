#!/usr/bin/env bash
set -eu

show_help() {
  printf "Usage:\n\
  %s --project-name <project_name> \
 [--inplace] \
 [--help]\n" "$0"
}

project_name=
is_inplace=false
while [ "$#" -gt 0 ] ; do
  key="$1"
  case $key in
    -n|--project-name)
      project_name="$2"
      shift ; shift
      ;;
    -i|--inplace)
      is_inplace=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ -z "$project_name" ] ; then
  show_help
  exit 1
fi


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

declare -a sed_args=("-E")
if $is_inplace ; then
  sed_args+=("-i.bak")
fi
generate_file() {
  local tmpl_file="$1"
  local tmpl_dir=
  local tmpl_name=
  local generated_file=
  tmpl_dir="$(dirname "$tmpl_file")"
  tmpl_name="$(basename "$tmpl_file" ".tmpl")"
  generated_file="${tmpl_dir}/${tmpl_name}"
  if $is_inplace ; then
    generated_file='/dev/null'
  fi
  >"$generated_file" sed "${sed_args[@]}" $'s/\x1eproject_name\x1e/'"${project_name}/g" "$tmpl_file"
  if ! $is_inplace ; then
    rm "$tmpl_file"
  fi
}

for ff in "${list_of_files[@]}" ; do
  generate_file "$ff"
done

git_add_file() {
  local tmpl_file=
  local tmpl_dir=
  local tmpl_name=
  local generated_file=
  for ff in "${list_of_files[@]}" ; do
    tmpl_file="$ff"
    tmpl_dir="$(dirname "$tmpl_file")"
    tmpl_name="$(basename "$tmpl_file" ".tmpl")"
    generated_file="${tmpl_dir}/${tmpl_name}"
    git add "$generated_file"
  done
}
git_add_file

git add -u
git commit -m 'add source'

# init git repo
git reset 82c6964
git checkout 5fa9db0 -- src/third/boost-cmake
git checkout 5fa9db0 -- src/lib/third/spdlog

git_add_file
git add bin/*.sh src/third/boost-cmake src/lib/third/spdlog
git add -u
git commit --amend -m 'Init'
