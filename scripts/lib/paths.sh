function set_paths() {
  output_dir="$(readlink -fm ../results/$1)"
  model_path="$output_dir/models"
  log_dir="$output_dir/logs"

  mkdir -p "$output_dir"
}
