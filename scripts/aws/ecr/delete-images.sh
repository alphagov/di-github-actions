# Delete docker images
set -eu

: "${IMAGE_DIGESTS}" # Digests of images to delete
: "${REPOSITORY}"    # ECR repository containing the images

read -ra digests < <(xargs <<< "$IMAGE_DIGESTS")

aws ecr batch-delete-image \
  --repository-name "$REPOSITORY" \
  --image-ids "${digests[@]/#/imageDigest=}" \
  --output json
