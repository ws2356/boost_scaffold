#!/usr/bin/env bash
# for vim ide

set -e

if [[ "$0" =~ ^/ ]] ; then
  this_file="$0"
else
  this_file="$(pwd)/$0"
fi
this_dir="$(dirname "$this_file")"
build_dir_vim=
. "${this_dir}/common.sh"

build_dir_name="$build_dir_vim"
root_dir="${this_dir}/.."
source_dir="$root_dir"
build_dir="${source_dir}/${build_dir_name}"
logfile="$(dirname "$0")/$(basename "$0" .sh).log"

{
  echo "=================================================================="
  echo "    $0: configuring ..."
  echo "    $(date)"
  echo "    log file is at: ${logfile}"
  echo "=================================================================="
} | tee "${logfile}"

cmake -S "${source_dir}" -B "${build_dir}" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  "-DBOOST_URL=${BOOST_URL:-http://localhost:8080/boost_1_69_0.tar.bz2}" \
  "-DBOOST_URL_SHA256=${BOOST_URL_SHA256:-8f32d4617390d1c2d16f26a27ab60d97807b35440d45891fa340fc2648b04406}" \
  -DBOOST_DISABLE_TESTS=ON | \
  tee -a "${logfile}"

compile_db="${build_dir}/compile_commands.json"
cur_compile_db="${root_dir}/compile_commands.json"
if [ -f "$compile_db" ] ; then
    if [ -f "$cur_compile_db" ] ; then
        rm "$cur_compile_db"
    fi
    ln -s "$compile_db" "$cur_compile_db"
fi
