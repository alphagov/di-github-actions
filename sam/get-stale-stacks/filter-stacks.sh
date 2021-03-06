set -eu

threshold=${THRESHOLD_DAYS}
name_filter=${STACK_NAME_FILTER}
env_var=${ENV_VAR_NAME}
description=${STACKS_DESCRIPTION}

declare -A tag_filters
eval "tag_filters=(${STACK_TAG_FILTERS})"

for name in "${!tag_filters[@]}"; do
  echo "Filtering by tag $name = ${tag_filters[$name]}"
done

if [[ $env_var ]]; then
  imported_stacks=()
  declare -n env_var_ref=$env_var
  read -ra imported_stacks <<< "${env_var_ref:-}"
  [[ ${#imported_stacks[@]} -gt 0 ]] && echo "Importing existing stacks: ${imported_stacks[*]}"
fi

cut_off_date=$(date -d "$threshold days ago" +%Y-%m-%d)
echo "Cut off date: $cut_off_date"

stacks=$(aws cloudformation describe-stacks | jq '.Stacks[]')

stack_names=$(jq -r '.StackName' <<< "$stacks")
[[ $name_filter ]] && stack_names=$(grep "$name_filter" <<< "$stack_names")
mapfile -t stack_names <<< "$stack_names"

stale_stacks=()
tag_names=("${!tag_filters[@]}")
for stack in "${stack_names[@]}"; do
  stack_info=$(jq --arg name "$stack" 'select(.StackName == $name)' <<< "$stacks")
  stack_tags=$(jq '.Tags[]' <<< "$stack_info")

  tag_idx=0
  exclude_stack=false
  while [[ $tag_idx -lt ${#tag_names[@]} ]] && ! $exclude_stack; do
    tag_name=${tag_names[((tag_idx++))]} && tag_filter=${tag_filters[$tag_name]}
    tag_value=$(jq -r --arg tagName "$tag_name" 'select(.Key == $tagName) | .Value' <<< "$stack_tags")
    [[ $tag_value == "$tag_filter" ]] || exclude_stack=true
  done

  $exclude_stack && continue
  last_updated_time=$(jq -r '.LastUpdatedTime' <<< "$stack_info")
  [[ $last_updated_time == null ]] && continue || last_updated_date=$(date -d "$last_updated_time" +%Y-%m-%d)
  [[ $last_updated_date < $cut_off_date ]] && stale_stacks+=("$stack")
  echo "$stack | last updated: $last_updated_date"
done

echo "::set-output name=stack-names::${stale_stacks[*]}"

if [[ $env_var ]]; then
  all_stacks=("${imported_stacks[@]}" "${stale_stacks[@]}")
  echo "Setting environment variable $env_var..."
  echo "$env_var=${all_stacks[*]}" >> "$GITHUB_ENV"
fi

if [[ ${#stale_stacks[@]} -gt 0 ]]; then
  echo "Stale ${description:+$description }stacks:" >> "$GITHUB_STEP_SUMMARY"
  for stack in "${stale_stacks[@]}"; do
    echo "  - $stack" >> "$GITHUB_STEP_SUMMARY"
  done
else
  echo "There are no stale ${description:+$description }stacks" >> "$GITHUB_STEP_SUMMARY"
fi

cat "$GITHUB_STEP_SUMMARY"
