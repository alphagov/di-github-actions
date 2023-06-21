# Wait for a pipeline to finish the execution with the given ID
set -eu

: "${PIPELINE_NAME}"
: "${EXECUTION_ID}"

echo -n "Waiting for the pipeline '$PIPELINE_NAME' to finish execution '$EXECUTION_ID'..."
query="pipelineExecutionSummaries[?pipelineExecutionId=='$EXECUTION_ID'].status"

while [[ ${status:-InProgress} == InProgress ]]; do
  status=$(aws codepipeline list-pipeline-executions --pipeline-name "$PIPELINE_NAME" --query "$query" --output text)
  echo -n "." && sleep 5
done

[[ $status == Succeeded ]] && exit
echo "Pipeline \`$PIPELINE_NAME\` finished execution with the status \`$status\`" | tee "$GITHUB_STEP_SUMMARY" && exit 1
