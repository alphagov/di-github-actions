set -eu

: "${ECS_FAMILY}"
: "${CONTAINER}"

deregistered_definitions=()
failed_definitions=()

task_definitions=$(aws ecs list-task-definitions \
  ${ECS_FAMILY:+--family-prefix $ECS_FAMILY} \
  --status ACTIVE \
  --query "taskDefinitionArns" \
  --output text)

read -ra task_definitions <<< "$task_definitions"
container_query="${CONTAINER:+?name=="'$CONTAINER'"}"

for task_definition in "${task_definitions[@]}"; do
  image=$(aws ecs describe-task-definition \
    --task-definition "$task_definition" \
    --query "taskDefinition.containerDefinitions[${container_query:-0}].image" \
    --output text)

  image_name="${image#*/}"
  image_repo="${image_name%%:*}"
  image_id="${image_name#*:}"

  if [[ $image_id =~ ^@(sha256:[a-fA-F0-9]+)$ ]]; then
    image_query="imageDigest=${BASH_REMATCH[1]}"
  else
    image_query="imageTag=$image_id"
  fi

  if ! aws ecr describe-images \
    --repository-name "$image_repo" \
    --image-ids "$image_query" > /dev/null 2>&1; then

    task_definition_version="${task_definition#*task-definition/}"
    echo "Image with ID '$image_query' not found in repository '$image_repo':" \
      "deregistering task definition '$task_definition_version'"

    aws ecs deregister-task-definition --task-definition "$task_definition" > /dev/null &&
      deregistered_definitions+=("$task_definition_version") ||
      failed_definitions+=("$task_definition_version")
  fi
done

echo "deregistered-definitions=${deregistered_definitions[*]}" >> "$GITHUB_OUTPUT"
echo "failed-definitions=${failed_definitions[*]}" >> "$GITHUB_OUTPUT"

[[ ${#failed_definitions[@]} -eq 0 ]] || exit 1
