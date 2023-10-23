# Get digests of ECR images associated with a list of tags
# Return an associative array of tag=digest pairs
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

: "${REPOSITORY}" # ECR repository name
: "${IMAGE_TAGS}" # Tags associated with the targeted images, delimited by spaces or newlines

read -ra tags < <(xargs <<< "$IMAGE_TAGS")
tags=("${tags[@]/#/\'}") && tags=("${tags[@]/%/\'}")
tag_list=$(IFS="," && echo "${tags[*]}")

aws ecr list-images \
  --repository-name "$REPOSITORY" \
  --query "imageIds[?contains([$tag_list], imageTag)].[imageDigest]" \
  --output text | sort -u | xargs
