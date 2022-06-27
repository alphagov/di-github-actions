set -eu

env_var=${SET_ENV_VAR}
read -ra stacks <<< "$(tr '\n' ' ' <<< "${STACK_NAMES}")"

print_summary=false
[[ ${VERBOSE} == true ]] && print_summary=true

real_stacks=()
fake_stacks=()
for stack in "${stacks[@]}"; do
  aws cloudformation describe-stacks --stack-name "$stack" > /dev/null && real_stacks+=("$stack") || fake_stacks+=("$stack")
done

echo "::set-output name=existing-stacks::${real_stacks[*]}"

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=${real_stacks[*]}" >> "$GITHUB_ENV"
fi

if [[ ${#real_stacks[@]} -eq 1 ]]; then
  echo "Stack \`${real_stacks[*]}\` exists" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#real_stacks[@]} -gt 1 ]]; then
  echo "Existing stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${real_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done
fi

if [[ ${#fake_stacks[@]} -eq 1 ]]; then
  echo "Stack \`${fake_stacks[*]}\` does not exist" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#fake_stacks[@]} -gt 1 ]]; then
  echo "Non-existent stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${fake_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done
fi

cat "$GITHUB_STEP_SUMMARY"
$print_summary || rm "$GITHUB_STEP_SUMMARY"
