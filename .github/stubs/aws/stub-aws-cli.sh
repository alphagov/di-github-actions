set -eu

[[ ${1:-} == help ]] && echo "Using stub AWS CLI"

if [[ ${1:-} == cloudformation && ${2:-} == describe-stacks ]]; then
  stacks="$(dirname "${BASH_SOURCE[0]}")/stacks.json"

  if [[ ${3:-} == --stack-name ]]; then
    stack_name="$4"
    stack_info=$(jq --arg stackName "$stack_name" '.Stacks[] | select(.StackName == $stackName)' < "$stacks")

    if [[ $stack_info ]]; then
      jq '{Stacks: [.]}' <<< "$stack_info"
      exit 0
    else
      echo "Stack $stack_name does not exist"
      exit 1
    fi
  fi

  cat "$stacks"
  exit 0
fi

echo "Unknown command: $*"
exit 1
