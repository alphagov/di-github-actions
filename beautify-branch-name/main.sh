#!/bin/sh -l

set -eu

branch_name=${INPUT_PREFIX:+$INPUT_PREFIX-}${INPUT_BRANCH_NAME:-${GITHUB_HEAD_REF:-$GITHUB_REF_NAME}}
downcase=${INPUT_DOWNCASE}
replace_underscores=${INPUT_UNDERSCORES_TO_HYPHENS}
length_limit=${INPUT_LENGTH_LIMIT}
env_var=${INPUT_SET_ENV_VAR}

if [ "$length_limit" -lt 1 ]; then
  echo "Invalid length limit: $length_limit - must be greater than 0"
  exit 1
fi

echo "Transforming $branch_name..."

$downcase && branch_name=$(echo "$branch_name" | tr '[:upper:]' '[:lower:]')
$replace_underscores && branch_name=$(echo "$branch_name" | tr '_' '-')
branch_name=$(echo "$branch_name" | cut -c1-"$length_limit")

echo "Beautified branch name: $branch_name"
echo "::set-output name=pretty_branch_name::$branch_name"

if [ -n "$env_var" ]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=$branch_name" >> "$GITHUB_ENV"
fi
