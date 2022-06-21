set -eu

env_var=${SET_ENV_VAR}
read -ra stacks <<< "${STACK_NAMES}"

existing_stacks=()
for stack in "${stacks[@]}"; do
  aws cloudformation describe-stacks --stack-name "$stack" > /dev/null && existing_stacks+=("$stack")
done

echo "::set-output name=existing-stacks::${existing_stacks[*]}"

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=${existing_stacks[*]}" >> "$GITHUB_ENV"
fi

if [[ ${#existing_stacks[@]} -gt 0 ]]; then
  echo "Existing stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${existing_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done

  cat "$GITHUB_STEP_SUMMARY"
fi
