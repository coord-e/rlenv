#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

set_paths $name

export OPENAI_LOG_FORMAT='stdout,log,csv,tensorboard'
export OPENAI_LOGDIR="$log_dir"

tensorboard --logdir "$log_dir" &
python ../run.py --save_path "$model_path" $@

trap 'pkill tensorboard' EXIT
