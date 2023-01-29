set -eu

: "${ECS_FAMILY}"
: "${CONTAINER}"
: "${REGISTRY:-}"

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
  image_repo="${image_name%:*}"
  image_tag="${image_name#*:}"

  if ! aws ecr describe-images \
    ${REGISTRY:+--registry-id $REGISTRY} \
    --repository-name "$image_repo" \
    --image-ids imageTag="$image_tag" > /dev/null; then

    task_definition_version="${task_definition#*task-definition/}"
    echo "Deregistering task definition $task_definition_version..."

    aws ecs deregister-task-definition --task-definition "$task_definition" > /dev/null &&
      deregistered_definitions+=("$task_definition_version") ||
      failed_definitions+=("$task_definition_version")
  fi
done

echo "deregistered-definitions=${deregistered_definitions[*]}" >> "$GITHUB_OUTPUT"
echo "failed-definitions=${failed_definitions[*]}" >> "$GITHUB_OUTPUT"

[[ ${#failed_definitions[@]} -eq 0 ]] || exit 1
