#!/usr/bin/env bash

set -eu

function pushd () {
  command pushd "$@" > /dev/null
}

function popd () {
  command popd "$@" > /dev/null
}

git init
git flow init

git submodule add https://github.com/coord-e/rlenv
pushd rlenv
git submodule update --init --recursive
popd

# Obtain the hash of baselines/roboschool in rlenv, and add them as a submodule
function get_hash() {
  pushd rlenv/$1
  git rev-parse HEAD
  popd
}

function add_and_checkout() {
  git submodule add https://github.com/$1
  pushd $(basename $1)
  git checkout $2
  popd
}

function reclone_submodule() {
  repo=$1
  dir=$(basename $repo)
  hash_rlenv=$(get_hash $dir)
  add_and_checkout $repo $hash_rlenv
}

reclone_submodule openai/baselines
reclone_submodule openai/roboschool
reclone_submodule olegklimov/bullet3

cp rlenv/template/* .

./setup.sh

echo results/ >> .gitignore
