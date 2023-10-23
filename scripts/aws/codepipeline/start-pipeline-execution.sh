# Start a pipeline execution and return the execution ID
set -eu

: "${PIPELINE_NAME}"

id=$(aws codepipeline start-pipeline-execution --name "$PIPELINE_NAME" --output text)
echo "Started execution for pipeline '$PIPELINE_NAME' with ID '$id'"
echo "execution-id=$id" >> "$GITHUB_OUTPUT"
