# Start a pipeline execution and return the execution ID
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

: "${PIPELINE_NAME}"

id=$(aws codepipeline start-pipeline-execution --name "$PIPELINE_NAME" --output text)
echo "Started execution for pipeline '$PIPELINE_NAME' with ID '$id'"
echo "execution-id=$id" >> "$GITHUB_OUTPUT"
