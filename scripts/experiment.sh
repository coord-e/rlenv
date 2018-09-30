#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

set_paths $name

export OPENAI_LOG_FORMAT='log,csv,tensorboard'

tensorboard --logdir "$log_dir" &
for i in $(seq 5); do
  export OPENAI_LOGDIR="$log_dir.$i"
  echo "train seed=$i"
  time python -m baselines.run --seed $i --save_path "${model_path}_$i" --num_timesteps 2e6 $@
done
