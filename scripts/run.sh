#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

cd ..
tmp_diff=$(mktemp)
git diff > $tmp_diff
head=$(git rev-parse HEAD)
patch_hash=$(sha1sum $tmp_diff | awk '{print $1}')
cd rlenv

set_paths $name-$head-$patch_hash
cp $tmp_diff $output_dir/changes.diff

echo "pipenv run train $name $@" > $output_dir/cmdline.txt

export OPENAI_LOG_FORMAT='stdout,log,csv,tensorboard'
export OPENAI_LOGDIR="$log_dir"

tensorboard --logdir "$log_dir" &
python ../run.py --seed 1 --save_path "$model_path" $@

trap 'pkill tensorboard' EXIT
