set -eu

: "${REPOSITORY}" # ECR repository name
: "${IMAGE_TAGS}" # Tags associated with the targeted images, delimited by spaces or newlines

read -ra tags <<< "$(tr '\n' ' ' <<< "$IMAGE_TAGS")"
tags=("${tags[@]/#/\'}") && tags=("${tags[@]/%/\'}")

tag_list=$(
  IFS=","
  echo "[${tags[*]}]"
)

image_list=$(aws ecr list-images \
  --repository-name "$REPOSITORY" \
  --query "imageIds[?contains($tag_list, imageTag)].[imageDigest]" \
  --output text | sort -u)

mapfile -t images <<< "$image_list"
echo "${images[*]}"