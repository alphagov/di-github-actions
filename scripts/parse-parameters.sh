set -eu

raw_parameters=$(echo -n "${PARAMETERS}")   # The parameters to parse
associative_arr=${ASSOCIATIVE_ARRAY:-false} # Whether to encode output as a string representing an associative array

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
  $associative_arr && element="[$name]='$value'" || element="$name='$value'"
  parsed_parameters+=("$element")
done

echo "${parsed_parameters[*]}"
