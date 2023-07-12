# Parse the JSON format output of the 'aws ecr batch-delete-image' command and pretty print it
set -eu

: "${RESULTS}"            # JSON output of the ecr:BatchDeleteImage operation
: "${REPOSITORY}"         # ECR repository the images were deleted from
: "${ERROR_STATUS:=true}" # Return error status if some images had failed to delete

base_dir="$(dirname "${BASH_SOURCE[0]}")"
report="$base_dir"/../../report-step-result/print-list.sh

deleted_digests=$(jq -r '.imageIds[].imageDigest' "$RESULTS" | sort -u)
failed_digests=$(jq -r '.failures[].imageId.imageDigest' "$RESULTS")

[[ $deleted_digests ]] && mapfile -t deleted_digests <<< "$deleted_digests" || deleted_digests=()
[[ $failed_digests ]] && mapfile -t failed_digests <<< "$failed_digests" || failed_digests=()

for digest in "${deleted_digests[@]}"; do
  tags=$(jq -r --arg digest "$digest" '.imageIds[] | select(.imageDigest == $digest) | .imageTag' "$RESULTS" | xargs)
  success_messages+=("$digest ($tags)")
done

for digest in "${failed_digests[@]}"; do
  failure_reason=$(jq -r --arg digest "$digest" '.failures[] | select(.imageId.imageDigest == $digest) | .failureReason' "$RESULTS")
  fail_messages+=("\`$digest\`: $failure_reason")
done

IFS=$'\n' && VALUES="${success_messages[*]}"$'\n' MESSAGE="Deleted images from repository \`${REPOSITORY}\`" \
  SINGLE_MESSAGE="Deleted image %s from repository \`${REPOSITORY}\`" $report | tee -a "$GITHUB_STEP_SUMMARY"

IFS=$'\n' && VALUES="${fail_messages[*]}"$'\n' MESSAGE="Failed to delete images from repository \`${REPOSITORY}\`" \
  SINGLE_MESSAGE="Failed to delete image from repository \`${REPOSITORY}\`"$'\n'%s CODE_BLOCK=false $report |
  tee -a "$GITHUB_STEP_SUMMARY"

[[ ${#failed_digests[@]} -gt 0 ]] && $ERROR_STATUS && exit 1 || exit 0
