set -eu

delete_only_failed=${ONLY_FAILED}
failed=()

read -ra stacks < <(xargs <<< "$STACK_NAMES")

for stack in "${stacks[@]}"; do
  if $delete_only_failed; then
    stack_state=$(aws cloudformation describe-stacks \
      --stack-name "$stack" \
      --query "Stacks[].StackStatus" \
      --output text)

    if ! [[ $stack_state =~ _FAILED$ ]]; then
      ignored+=("$stack")
      continue
    fi
  fi

  sam delete --no-prompts --region "$AWS_REGION" --stack-name "$stack" && deleted+=("$stack") || failed+=("$stack")
done

{
  echo "deleted-stacks=${deleted[*]}"
  echo "failed-stacks=${failed[*]}"
  echo "ignored-stacks=${ignored[*]}"
} >> "$GITHUB_OUTPUT"

[[ ${#failed[@]} -eq 0 ]] || exit 1
