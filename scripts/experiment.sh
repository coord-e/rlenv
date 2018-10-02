#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

set_paths $name

export OPENAI_LOG_FORMAT='log,csv,tensorboard'

for i in $(seq 5); do
  LOG_PATH="$log_dir.$i"
  tensorboard --logdir "$LOG_PATH" &
  export OPENAI_LOGDIR="$LOG_PATH"
  echo "train seed=$i"
  time python ../run.py --seed $i --save_path "${model_path}_$i" --num_timesteps 2e6 $@
  pkill tensorboard
done

trap 'pkill tensorboard' EXIT
