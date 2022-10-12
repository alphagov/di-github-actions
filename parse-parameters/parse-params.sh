set -eu

raw_parameters=$(echo -n "${PARAMS}")
associative_arr=${ASSOCIATIVE_ARRAY}
env_var=${ENV_VAR_NAME}

num_lines=$(wc -l <<< "$raw_parameters")
if [[ $num_lines -le 1 ]]; then
  IFS="|" read -ra key_value_pairs <<< "$raw_parameters"
else
  mapfile -t key_value_pairs <<< "$raw_parameters"
fi

parameters=()
for kvp in "${key_value_pairs[@]}"; do
  IFS="=" read -r name value < <(xargs <<< "$kvp")
  name=$(xargs <<< "$name") && value=$(xargs <<< "$value")
  $associative_arr && element="[$name]='$value'" || element="$name='$value'"
  parameters+=("$element")
done

echo "parsed-parameters=${parameters[*]}" >> "$GITHUB_OUTPUT"

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=${parameters[*]}" >> "$GITHUB_ENV"
fi

echo "Parsed ${#parameters[@]} parameters"
