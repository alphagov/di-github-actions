set -eu

branch_name=${PREFIX:+$PREFIX-}${BRANCH_NAME:-${GITHUB_HEAD_REF:-$GITHUB_REF_NAME}}
replace_underscores=${UNDERSCORES_TO_HYPHENS}
tidy_dependabot=${TIDY_DEPENDENCY_BOT_BRANCH}
length_limit=${TOTAL_LENGTH_LIMIT}
downcase=${DOWNCASE_NAME}
env_var=${SET_ENV_VAR}
message=${USAGE}

if [[ $length_limit -lt 1 ]]; then
  echo "Invalid length limit: $length_limit - must be greater than 0"
  exit 1
fi

echo "Transforming $branch_name..."

$downcase && branch_name=$(echo "$branch_name" | tr '[:upper:]' '[:lower:]')
$replace_underscores && branch_name=$(echo "$branch_name" | tr '_' '-')
$tidy_dependabot && branch_name=$(echo "$branch_name" | sed -e 's/dependabot\//db/g' -e 's/gradle//g' -e 's/npm_and_yarn//g' -e 's/-function//g' -e 's/\./-/g' -e 's/\//-/g')
branch_name=$(echo "$branch_name" | cut -c1-"$length_limit")

echo "::set-output name=pretty-branch-name::$branch_name"

if [[ $env_var ]]; then
  echo "Setting environment variable $env_var..."
  echo "$env_var=$branch_name" >> "$GITHUB_ENV"
fi

echo "${message:-Pretty branch name}: \`$branch_name\`" >> "$GITHUB_STEP_SUMMARY"
cat "$GITHUB_STEP_SUMMARY"
