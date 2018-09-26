function set_paths() {
  output_dir="./results/$name"
  model_dir="$output_dir/models"
  log_dir="$output_dir/logs"

  mkdir -p "$output_dir"
}
