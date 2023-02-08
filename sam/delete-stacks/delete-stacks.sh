set -eu

region=${AWS_REGION}
delete_only_failed=${ONLY_FAILED}

deleted_stacks=()
failed_stacks=()

read -ra stacks < <(xargs <<< "${STACK_NAMES}")

for stack in "${stacks[@]}"; do
  if $delete_only_failed; then
    stack_info=$(aws cloudformation describe-stacks --stack-name "$stack")
    stack_state=$(jq -r '.Stacks[].StackStatus' <<< "$stack_info")

    if ! [[ $stack_state =~ FAILED ]]; then
      echo "Stack '$stack' is in a good state: '$stack_state' - not deleting"
      continue
    fi
  fi

  sam delete --no-prompts --region "$region" --stack-name "$stack" && deleted_stacks+=("$stack") || failed_stacks+=("$stack")
done

echo "deleted-stacks=${deleted_stacks[*]}" >> "$GITHUB_OUTPUT"
echo "failed-stacks=${failed_stacks[*]}" >> "$GITHUB_OUTPUT"

[[ ${#failed_stacks[@]} -eq 0 ]] || exit 1
