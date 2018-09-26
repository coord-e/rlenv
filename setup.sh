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

# Bullet installation for roboschool
roboschool_path=$(realpath ./roboschool)
mkdir -p bullet3/build
pushd    bullet3/build
cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 -DCMAKE_INSTALL_PREFIX:PATH=$roboschool_path/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF ..
make -j"$(nproc)"
make install
popd

if type "nvidia-smi" > /dev/null 2>&1
then
  sed -i 's/tensorflow/tensorflow-gpu/' Pipfile
else
  echo "Using tensorflow without GPU support"
fi

# Roboschool installation needs to be done in virtualenv
pipenv run pipenv install

echo results/ >> .gitignore
