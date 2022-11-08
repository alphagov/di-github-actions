set -eu

: "${VALUES}"           # Values to append to the job summary, space or newline-delimited string
: "${MESSAGE}"          # Message to print before the list
: "${SINGLE_MESSAGE:=}" # Message to print when the list contains a single element; use the token %s to insert the value
: "${CODE_BLOCK:=true}" # Print the values in a code block

$CODE_BLOCK && code_block_char="\`"
read -ra list <<< "$(tr '\n' ' ' <<< "$VALUES")"

if [[ ${#list[@]} -eq 0 ]]; then
  echo "No elements to print"
  exit 1
fi

if [[ ${#list[@]} -eq 1 ]]; then
  value="${code_block_char:-}${list[*]}${code_block_char:-}"

  if [[ $SINGLE_MESSAGE =~ %s ]]; then
    echo "${SINGLE_MESSAGE//%s/$value}"
  else
    echo "${SINGLE_MESSAGE:-$MESSAGE}: $value"
  fi
else
  echo "$MESSAGE:"
  for value in "${list[@]}"; do
    echo "  - ${code_block_char:-}$value${code_block_char:-}"
  done
  echo
fi
