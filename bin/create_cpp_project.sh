#!/usr/bin/env bash
set -eu

project_name=
for ((i = 0; i < "$#"; i++)) ; do
  argi="${@:i+1:1}"
  if [ "$argi" != "-n" ] && [ "$argi" != "--project-name" ] ; then
    continue
  fi
  if [ "$((i+1))" -lt "$#" ] ; then
    project_name="${@:i+2:1}"
  fi
done
if [ -z "$project_name" ] ; then
  echo -e "Usage: $0 <-n|--project_name> <project_name>"
  exit 1
fi

if [ -e "$project_name" ] ; then
  echo "project: $project_name already exists!"
  exit 1
fi

tmpl_repo='https://github.com/ws2356/boost_scaffold.git'
tmp_path="$(mktemp -d '/tmp/boost_scaffold.XXXXXX')"
git clone "$tmpl_repo" "$tmp_path"
(cd "$tmp_path" && bin/do_create.sh "$@")

mv "$tmp_path" "$project_name"
