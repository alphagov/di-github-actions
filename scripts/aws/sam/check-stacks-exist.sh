# Returns a JSON object with entries for existing and missing stacks
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

jq --null-input --compact-output \
  --arg existingStacks "${existing_stacks[*]}" --arg missingStacks "${missing_stacks[*]}" \
  '{"existing-stacks": $existingStacks, "missing-stacks": $missingStacks}'
