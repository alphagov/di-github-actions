set -eu

read -ra stacks <<< "${STACK_NAMES}"
region=${AWS_REGION}

delete_only_failed=false
[[ ${ONLY_FAILED} == true ]] && delete_only_failed=true

for stack in "${stacks[@]}"; do
  if $delete_only_failed; then
    stack_info=$(aws cloudformation describe-stacks --stack-name "$stack")
    stack_state=$(jq -r '.Stacks[].StackStatus' <<< "$stack_info")

    if ! [[ $stack_state =~ FAILED ]]; then
      echo "Stack $stack is in a good state: $stack_state - not deleting"
      continue
    fi
  fi

  sam delete --no-prompts --region "$region" --stack-name "$stack"
done
