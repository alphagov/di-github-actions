set -eu

existing_stacks=()
missing_stacks=()

env_var=${SET_ENV_VAR}

read -ra stacks <<< "$(tr '\n' ' ' <<< "${STACK_NAMES}")"

for stack in "${stacks[@]}"; do
  if aws cloudformation describe-stacks --stack-name "$stack" > /dev/null; then
    existing_stacks+=("$stack")
  else
    missing_stacks+=("$stack")
  fi
done

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=${existing_stacks[*]}" >> "$GITHUB_ENV"
fi

echo "existing-stacks=${existing_stacks[*]}" >> "$GITHUB_OUTPUT"
echo "missing-stacks=${missing_stacks[*]}" >> "$GITHUB_OUTPUT"
