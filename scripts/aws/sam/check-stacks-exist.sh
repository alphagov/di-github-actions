# Returns two arrays with existing and missing stacks
set -eu

: "${STACK_NAMES}" # Names of the stacks to check (space or newline-delimited string)

read -ra stacks < <(xargs <<< "$STACK_NAMES")

for stack in "${stacks[@]}"; do
  if aws cloudformation describe-stacks --stack-name "$stack" > /dev/null; then
    existing_stacks+=("$stack")
  else
    missing_stacks+=("$stack")
  fi
done

echo "existing-stacks=${existing_stacks[*]}" >> "$GITHUB_OUTPUT"
echo "missing-stacks=${missing_stacks[*]}" >> "$GITHUB_OUTPUT"
