set -eu

: "${STACK_NAMES}" # Names of the stacks to check (space or newline-delimited string)

read -ra stacks <<< "$(tr '\n' ' ' <<< "${STACK_NAMES}")"

for stack in "${stacks[@]}"; do
  if aws cloudformation describe-stacks --stack-name "$stack" > /dev/null; then
    existing_stacks+=("$stack")
  else
    missing_stacks+=("$stack")
  fi
done

results+=("[existing-stacks]='${existing_stacks[*]}'")
results+=("[missing-stacks]='${missing_stacks[*]}'")

echo "${results[*]}"
