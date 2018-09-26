#!/usr/bin/env bash

cd "$(dirname $0)/.."

source scripts/lib/paths.sh

name=$1
shift

set_paths $name

python -m baselines.run --load_path "$model_path" --play $@
