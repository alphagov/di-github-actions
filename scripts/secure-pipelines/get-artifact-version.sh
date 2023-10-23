# Get version ID of an uploaded SAM artifact
set -eu
echo "::warning title=alphagov/di-github-actions::The repository hosting this upload action has been archived. New location https://github.com/govuk-one-login/github-actions"

: "${ARTIFACT_BUCKET}"    # The artifact upload bucket
: "${ERROR_STATUS:=true}" # Return error status if the artifact doesn't correspond to the commit SHA

if ! artifact=$(aws s3api head-object --bucket "$ARTIFACT_BUCKET" --key template.zip) ||
  [[ $(jq --raw-output '.Metadata.commitsha' <<< "$artifact") != "$GITHUB_SHA" ]]; then
  $ERROR_STATUS || exit 0
  echo "Artifact not found for commit SHA \`$GITHUB_SHA\`" | tee "$GITHUB_STEP_SUMMARY" && exit 1
fi

echo "artifact-version=$(jq --raw-output '.VersionId' <<< "$artifact")" >> "$GITHUB_OUTPUT"
echo "artifact-timestamp=$(jq --raw-output '.LastModified' <<< "$artifact")" >> "$GITHUB_OUTPUT"
