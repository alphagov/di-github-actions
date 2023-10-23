# Check if a docker image with the specified tags exists in a repository.
# Return the image digest, if it exists, and optionally print a message to the step summary.
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

base_dir="$(dirname "${BASH_SOURCE[0]}")"

: "${REGISTRY:-}"     # ECR registry ID
: "${REPOSITORY}"     # ECR repository name
: "${IMAGE_TAGS}"     # Tags associated with the targeted images, delimited by spaces or newlines
: "${VERBOSE:=false}" # Do not print a message to the step summary

image_digests=$("$base_dir"/get-image-digests.sh)
[[ $image_digests ]] && read -ra images <<< "$image_digests" || exit 0

if [[ ${#images[@]} -gt 1 ]]; then
  echo "::error::Expected only one image with tags '$IMAGE_TAGS' but got multiple: ${images[*]}" >&2
  exit 1
fi

[[ ${#images[@]} -eq 1 ]] || exit 0

digest=${images[*]}
[[ ${REGISTRY:-} ]] || REGISTRY=$(aws ecr describe-registry --query "registryId" --output text)
url="https://${AWS_REGION}.console.aws.amazon.com/ecr/repositories/private/${REGISTRY}/${REPOSITORY}/_/image/${digest}/details"

if $VERBOSE; then
  read -ra tags < <(xargs <<< "$IMAGE_TAGS")
  [[ ${#tags[@]} -gt 1 ]] && plural=true
  echo "🐳 [Image with tag${plural:+s} \`${tags[*]}\`]($url) exists in repository \`$REPOSITORY\`" >> "$GITHUB_STEP_SUMMARY"
fi

echo "image-digest=$digest" >> "$GITHUB_OUTPUT"
echo "image-url=$url" >> "$GITHUB_OUTPUT"
