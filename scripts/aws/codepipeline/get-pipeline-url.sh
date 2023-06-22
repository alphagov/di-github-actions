# Get the AWS Console URL of a CodePipeline pipeline
set -eu

: "${PIPELINE_NAME}"
: "${REGION:=eu-west-2}"

url="https://${REGION}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${PIPELINE_NAME}/view"
echo "pipeline-url=$url" >> "$GITHUB_OUTPUT"
