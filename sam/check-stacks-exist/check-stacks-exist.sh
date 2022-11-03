set -eu

existing_stacks=()
missing_stacks=()

read -ra stacks <<< "$(tr '\n' ' ' <<< "${STACK_NAMES}")"

for stack in "${stacks[@]}"; do
  if aws cloudformation describe-stacks --stack-name "$stack" > /dev/null; then
    existing_stacks+=("$stack")
  else
    missing_stacks+=("$stack")
  fi
done

echo "existing-stacks=${existing_stacks[*]}" >> "$GITHUB_OUTPUT"
echo "missing-stacks=${missing_stacks[*]}" >> "$GITHUB_OUTPUT"
