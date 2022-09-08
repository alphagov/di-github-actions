set -eu

branch_name=${PREFIX:+$PREFIX-}${BRANCH_NAME:-${GITHUB_HEAD_REF:-$GITHUB_REF_NAME}}
replace_underscores=${UNDERSCORES_TO_HYPHENS}
length_limit=${TOTAL_LENGTH_LIMIT}
downcase=${DOWNCASE_NAME}
env_var=${SET_ENV_VAR}
message=${USAGE}

if [[ $length_limit -lt 1 ]]; then
  echo "Invalid length limit: $length_limit - must be greater than 0"
  exit 1
fi

echo "Transforming $branch_name..."

branch_name=$(echo "$branch_name" | tr "." "_" | tr "/" "_")
$downcase && branch_name=$(echo "$branch_name" | tr "[:upper:]" "[:lower:]")
$replace_underscores && branch_name=$(echo "$branch_name" | tr "_" "-")
branch_name=$(echo "$branch_name" | cut -c1-"$length_limit")

echo "::set-output name=pretty-branch-name::$branch_name"

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=$branch_name" >> "$GITHUB_ENV"
fi

echo "${message:-Pretty branch name}: \`$branch_name\`" >> "$GITHUB_STEP_SUMMARY"
cat "$GITHUB_STEP_SUMMARY"
