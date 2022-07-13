set -eu

region=${AWS_REGION}
delete_only_failed=${ONLY_FAILED}

read -ra stacks <<< "$(tr '\n' ' ' <<< "${STACK_NAMES}")"

deleted_stacks=()
failed_stacks=()
for stack in "${stacks[@]}"; do
  if $delete_only_failed; then
    stack_info=$(aws cloudformation describe-stacks --stack-name "$stack")
    stack_state=$(jq -r '.Stacks[].StackStatus' <<< "$stack_info")

    if ! [[ $stack_state =~ FAILED ]]; then
      echo "Stack $stack is in a good state: $stack_state - not deleting"
      continue
    fi
  fi

  sam delete --no-prompts --region "$region" --stack-name "$stack" && deleted_stacks+=("$stack") || failed_stacks+=("$stack")
done

if [[ ${#deleted_stacks[@]} -eq 1 ]]; then
  echo "Deleted stack \`${deleted_stacks[*]}\`" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#deleted_stacks[@]} -gt 1 ]]; then
  echo "Deleted stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${deleted_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done
fi

if [[ ${#failed_stacks[@]} -eq 1 ]]; then
  echo "Failed to delete stack \`${failed_stacks[*]}\`" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#failed_stacks[@]} -gt 1 ]]; then
  echo "Failed to delete stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${failed_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done
fi

cat "$GITHUB_STEP_SUMMARY"
