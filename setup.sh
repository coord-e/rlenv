#!/usr/bin/env bash

git init
git flow init

git submodule add https://github.com/coord-e/rlenv

# Obtain the hash of baselines/roboschool in rlenv, and add them as a submodule
function get_hash() {
  cd rlenv/$1
  git rev-parse HEAD
}

hash_baselines=$(get_hash baselines)
hash_roboschool=$(get_hash roboschool)

function add_and_checkout() {
  git submodule add https://github.com/$1
  cd $(basename $1)
  git checkout $2
}

add_and_checkout openai/baselines $hash_baselines
add_and_checkout openai/roboschool $hash_roboschool

cp rlenv/template/* .

# Bullet installation for roboschool
roboschool_path=$(realpath ./roboschool)
mkdir -p bullet3/build
pushd    bullet3/build
cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 -DCMAKE_INSTALL_PREFIX:PATH=$roboschool_path/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF ..
make -j"$(nproc)"
make install
popd

# Roboschool installation needs to be done in virtualenv
pipenv run pipenv install

echo results/ >> .gitignore
