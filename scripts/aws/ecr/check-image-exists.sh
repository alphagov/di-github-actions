# Check if a docker image with the specified tags exists in a repository.
# Return the image digest, if it exists, and optionally print a message to the step summary.
set -eu

: "${REPOSITORY}"   # ECR repository name
: "${IMAGE_TAGS}"   # Tags associated with the targeted images, delimited by spaces or newlines
: "${QUIET:=false}" # Do not print a message to the step summary

base_dir="$(dirname "${BASH_SOURCE[0]}")"

image_digests=$("$base_dir"/get-image-digests.sh)
[[ $image_digests ]] && read -ra images <<< "$image_digests" || exit 0

if [[ ${#images[@]} -gt 1 ]]; then
  echo "::error::Expected only one image with tags '$IMAGE_TAGS' but got multiple: ${images[*]}"
  exit 1
fi

if [[ ${#images[@]} -eq 1 ]] && ! $QUIET; then
  read -ra tags <<< "$(tr '\n' ' ' <<< "$IMAGE_TAGS")"
  [[ ${#tags[@]} -gt 1 ]] && plural=true
  echo "Image with tag${plural:+s} \`${tags[*]}\` exists in repository \`$REPOSITORY\`" >> "$GITHUB_STEP_SUMMARY"
fi

echo "${images[*]}"
