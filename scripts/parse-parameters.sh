set -eu

: "${PARAMETERS}"               # The parameters to parse
: "${ASSOCIATIVE_ARRAY:=false}" # Whether to encode output as a string representing an associative array
: "${LONG_FORMAT:=false}"       # Whether to encode the parameters in the form of "key=key,value='value'" strings

raw_parameters=$(echo -n "${PARAMETERS}")
associative=${ASSOCIATIVE_ARRAY}
long=${LONG_FORMAT}

num_lines=$(wc -l <<< "$raw_parameters")
if [[ $num_lines -le 1 ]]; then
  IFS="|" read -ra key_value_pairs <<< "$raw_parameters"
else
  mapfile -t key_value_pairs <<< "$raw_parameters"
fi

parsed_parameters=()
for kvp in "${key_value_pairs[@]}"; do
  IFS="=" read -r name value < <(xargs <<< "$kvp")
  name=$(xargs <<< "$name") && value="'$(xargs <<< "$value")'"

  if $associative; then
    element="[$name]=$value"
  else
    $long && element="key=$name,value=$value" || element="$name=$value"
  fi

  parsed_parameters+=("$element")
done

echo "${parsed_parameters[*]}"
