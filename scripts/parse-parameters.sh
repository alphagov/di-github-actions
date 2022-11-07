set -eu

: "${PARAMETERS}"               # The parameters to parse
: "${ASSOCIATIVE_ARRAY:=false}" # Whether to encode output as a string representing an associative array
: "${ENV_VAR:-}"                # Name of the environment variable to set

raw_parameters=$(echo -n "${PARAMETERS}")
associative=${ASSOCIATIVE_ARRAY}

num_lines=$(wc -l <<< "$raw_parameters")
if [[ $num_lines -le 1 ]]; then
  IFS="|" read -ra key_value_pairs <<< "$raw_parameters"
else
  mapfile -t key_value_pairs <<< "$raw_parameters"
fi

parsed_parameters=()
for kvp in "${key_value_pairs[@]}"; do
  IFS="=" read -r name value < <(xargs <<< "$kvp")
  name=$(xargs <<< "$name") && value=$(xargs <<< "$value")
  $associative && element="[$name]='$value'" || element="$name='$value'"
  parsed_parameters+=("$element")
done

if [[ $ENV_VAR ]]; then
  echo "Setting environment variable $ENV_VAR..."
  echo "$ENV_VAR=${parsed_parameters[*]}" >> "$GITHUB_ENV"
fi

echo "${parsed_parameters[*]}"
