set -eu

: "${PREFIX:=}"                  # '${prefix}-' will be prepended to the returned string; included in the length limit
: "${BRANCH_NAME:=}"             # Override the branch name to transform
: "${LENGTH_LIMIT:=200}"         # Maximum length of the returned string
: "${REPLACE_UNDERSCORES:=true}" # Whether to replace all underscores with hyphens
: "${DOWNCASE:=true}"            # Whether to downcase all letters in the branch name

branch_name=${PREFIX:+$PREFIX-}${BRANCH_NAME:-${GITHUB_HEAD_REF:-$GITHUB_REF_NAME}}

if [[ $LENGTH_LIMIT -lt 1 ]]; then
  echo "Invalid length limit: $LENGTH_LIMIT - must be greater than 0"
  exit 1
fi

branch_name=$(echo "$branch_name" | cut -c1-"$LENGTH_LIMIT")
branch_name=$(echo "$branch_name" | tr "." "_" | tr "/" "_")
$DOWNCASE && branch_name=$(echo "$branch_name" | tr "[:upper:]" "[:lower:]")
$REPLACE_UNDERSCORES && branch_name=$(echo "$branch_name" | tr "_" "-")

echo "${branch_name%%[-_]}"
