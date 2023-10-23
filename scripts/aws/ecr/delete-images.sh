# Delete docker images
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

: "${IMAGE_DIGESTS}" # Digests of images to delete
: "${REPOSITORY}"    # ECR repository containing the images

read -ra digests < <(xargs <<< "$IMAGE_DIGESTS")

aws ecr batch-delete-image \
  --repository-name "$REPOSITORY" \
  --image-ids "${digests[@]/#/imageDigest=}" \
  --output json
