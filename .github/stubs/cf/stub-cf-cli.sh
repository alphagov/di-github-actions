set -eu

cmd=${1:-}

if [[ $cmd == push ]]; then
  if ! [[ ${2:-} =~ "--" ]]; then
    app_name=$2
  fi

  param_idx=0
  while [[ $((param_idx++)) -lt $# ]]; do
    if [[ ${!param_idx} == "--vars-file" ]]; then
      ((param_idx++)) && vars_file=${!param_idx}
      break
    fi
  done

  echo "PUSHED_APP_NAME=${app_name:-}" >> "$GITHUB_ENV"
  echo "VARS_FILE=${vars_file:-}" >> "$GITHUB_ENV"
fi

echo "Running command $cmd..."
