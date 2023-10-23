# Get the AWS Console URL of a CodePipeline pipeline
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

: "${PIPELINE_NAME}"
: "${REGION:=eu-west-2}"

url="https://${REGION}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${PIPELINE_NAME}/view"
echo "pipeline-url=$url" >> "$GITHUB_OUTPUT"
