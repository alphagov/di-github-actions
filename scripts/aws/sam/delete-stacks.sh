# Returns four arrays with deleted, failed, ignored and missing stacks

set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

base_dir="$(dirname "${BASH_SOURCE[0]}")"
report="$base_dir"/../../report-step-result/print-list.sh
failed=()

: "${STACK_NAMES}" # Names of the stacks to delete (space or newline-delimited string)
: "${ONLY_FAILED}" # Whether to only delete stacks in one of the failed states

stacks=$("$base_dir"/check-stacks-exist.sh)
missing=$(jq --raw-output '."missing-stacks"' <<< "$stacks")
existing=$(jq --raw-output '."existing-stacks"' <<< "$stacks")
read -ra stacks <<< "$existing"

for stack in "${stacks[@]}"; do
  if $ONLY_FAILED; then
    stack_state=$(aws cloudformation describe-stacks \
      --stack-name "$stack" \
      --query "Stacks[].StackStatus" \
      --output text)

    if ! [[ $stack_state =~ _FAILED$|^ROLLBACK_COMPLETE$ ]]; then
      ignored+=("$stack")
      continue
    fi
  fi

  sam delete --no-prompts --region "$AWS_REGION" --stack-name "$stack" && deleted+=("$stack") || failed+=("$stack")
done

VALUES=${missing[*]} MESSAGE="Non-existent stacks" SINGLE_MESSAGE="Stack %s does not exist" $report
VALUES=${ignored[*]} MESSAGE="Ignored stacks in a good state" SINGLE_MESSAGE="Ignored stack %s in a good state" $report

VALUES=${deleted[*]} MESSAGE="🚮 Deleted stacks" SINGLE_MESSAGE="🚮 Deleted stack %s" $report |
  tee -a "$GITHUB_STEP_SUMMARY"

VALUES=${failed[*]} MESSAGE="❌ Failed to delete stacks" SINGLE_MESSAGE="❌ Failed to delete stack %s" $report |
  tee -a "$GITHUB_STEP_SUMMARY"

{
  echo "deleted-stacks=${deleted[*]}"
  echo "failed-stacks=${failed[*]}"
  echo "ignored-stacks=${ignored[*]}"
  echo "missing-stacks=${missing[*]}"
} >> "$GITHUB_OUTPUT"

[[ ${#failed[@]} -eq 0 ]] || exit 1
