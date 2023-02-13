set -eu

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

  [[ -z ${query:-} ]] || stacks=$(jq ".$query" <<< "$stacks")
  [[ ${output:-} != text ]] || stacks=$(jq -r <<< "$stacks")

  echo "$stacks"
  exit 0
fi

echo "Unknown command: $*"
exit 1
