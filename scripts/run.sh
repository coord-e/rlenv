#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

cd ..
head=$(git rev-parse HEAD)
patch_hash=$(sha1sum <<< $(git diff) | awk '{print $1}')
cd rlenv

set_paths $name-${head:0:6}-${patch_hash:0:6}

cd ..
function save_changes() {
  name=$1
  path=$2
  pushd $path > /dev/null
  git diff > $output_dir/$name.diff
  popd > /dev/null
}

save_changes changes .

for submodule in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
  save_changes ./$submodule $submodule
done
cd rlenv

echo "pipenv run train $name $@" > $output_dir/cmdline.txt

export OPENAI_LOG_FORMAT='stdout,log,csv,tensorboard'
export OPENAI_LOGDIR="$log_dir"

tensorboard --logdir "$log_dir" --port 0 &
tb_pid=$!
python ../run.py --seed 1 --save_path "$model_path" $@

trap "kill $tb_pid" EXIT
