# Get version ID of an uploaded SAM artifact
set -eu

: "${ARTIFACT_BUCKET}" # The artifact upload bucket

artifact=$(aws s3api head-object --bucket "$ARTIFACT_BUCKET" --key template.zip | jq '{VersionId, Metadata}')
[[ $(jq --raw-output '.Metadata.commitsha' <<< "$artifact") != "$GITHUB_SHA" ]] && echo "Invalid commit SHA" && exit 1
echo "artifact-version=$(jq --raw-output '.VersionId' <<< "$artifact")" >> "$GITHUB_OUTPUT"
