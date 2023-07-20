set -eu
OPTION_REGEX="^--?.*"

[[ ${1:-} == help ]] && echo "Using stub AWS CLI"

if [[ ${1:-} == cloudformation && ${2:-} == describe-stacks ]]; then
  stacks=$(cat "$(dirname "${BASH_SOURCE[0]}")/stacks.json")

  set -- "${@:3}"
  while [[ ${1:-} ]]; do
    case $1 in
      --stack-name) shift && stack_name=$1 ;;
      --query) shift && query=$1 ;;
      --output) shift && output=$1 ;;
    esac
    shift
  done

  if [[ ${stack_name:-} ]]; then
    stack_info=$(jq --arg stackName "$stack_name" '.Stacks[] | select(.StackName == $stackName)' <<< "$stacks")
    [[ $stack_info ]] || (echo "Stack $stack_name does not exist" && exit 1)
    stacks=$(jq '{Stacks: [.]}' <<< "$stack_info")
  fi

  [[ ${query:-} ]] && stacks=$(jp "$query" <<< "$stacks")
  [[ ${output:-} == text ]] && stacks=$(jq --raw-output '.[]?' <<< "$stacks")

  echo "$stacks"
  exit 0
fi

if [[ ${1:-} == ssm ]] && [[ ${2:-} == get-parameters || ${2:-} == get-parameters-by-path ]]; then
  parameters="$(dirname "${BASH_SOURCE[0]}")/parameters.json"

  set -- "${@:3}"
  while [[ ${1:-} ]]; do
    case $1 in
      --names)
        while [[ ${2:-} ]] && ! [[ $2 =~ $OPTION_REGEX ]]; do
          shift && names+=("$1")
        done
        ;;
      --path) shift && parameter_path=$1 ;;
      --recursive) recursive=true ;;
      --output) shift && output=$1 ;;
    esac
    shift
  done

  if [[ ${names[*]} ]]; then
    names=("${names[@]/#/\"}") && names=("${names[@]/%/\"}") && keys="$(IFS="," && echo "${names[*]}")"
    params=$(jq "{$keys} | to_entries" "$parameters")
  fi

  if [[ ${parameter_path:-} ]]; then
    ${recursive:-false} || filter=$' | map(select(.key | ltrimstr($path) | contains("/") | not))'
    params=$(jq --arg path "${parameter_path%/}/" \
      'to_entries | map(select(.key | startswith($path)))'"${filter:-}" "$parameters")
  fi

  invalid_params=$(jq 'map(select(.value == null) | .key)' <<< "$params")
  valid_params=$(jq 'map(select(.value != null)) | map({Name: .key, Value: .value})' <<< "$params")

  params=$(jq --null-input --argjson params "$valid_params" --argjson invalidParams "$invalid_params" \
    '{Parameters: $params, InvalidParameters: $invalidParams}')

  [[ ${output:-} == text ]] && params=$(jq --raw-output '.[]?' <<< "$params")

  echo "$params"
  exit 0
fi

if [[ ${1:-} == s3 ]] && [[ ${2:-} == cp || ${2:-} ]]; then
  exit 0
fi

if [[ ${1:-} == kms ]] && [[ ${2:-} == sign || ${2:-} ]]; then
  echo "dGVzdGluZw=="
  exit 0
fi

echo "Unknown command: $*"
exit 1
