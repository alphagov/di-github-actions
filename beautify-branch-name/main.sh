#!/bin/sh -l

set -eu

branch_name=${GITHUB_HEAD_REF:-$GITHUB_REF_NAME}
downcase=$INPUT_DOWNCASE
replace_underscores=$INPUT_UNDERSCORESTOHYPHENS
length_limit=$INPUT_LENGTHLIMIT

if [ "$length_limit" -lt 1 ]; then
  echo "Invalid length limit: $length_limit - must be greater than 0"
  exit 1
fi

echo "Transforming $branch_name..."

$downcase && branch_name=$(echo "$branch_name" | tr '[:upper:]' '[:lower:]')
$replace_underscores && branch_name=$(echo "$branch_name" | tr '_' '-')
branch_name=$(echo "$branch_name" | cut -c1-"$length_limit")

echo "Beautified branch name: $branch_name"
echo "::set-output name=prettyBranchName::$branch_name"
