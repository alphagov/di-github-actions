# Get a pipeline execution ID for a given revision ID that started after a given timestamp
set -eu

: "${PIPELINE_NAME}"
: "${REVISION_ID}"     # The artifact version that triggered the execution
: "${STARTED_AFTER:-}" # Look for an execution whose start time is after the given timestamp
: "${TIMEOUT_MINS:-5}" # Maximum number of minutes to wait for the execution to start

[[ $STARTED_AFTER ]] && start=$(date --date="$STARTED_AFTER" +%s)
[[ $TIMEOUT_MINS ]] && timeout=$((TIMEOUT_MINS * 60)) elapsed=0

echo -n "Waiting for the pipeline '$PIPELINE_NAME' to start execution for revision '$REVISION_ID'..."
query="pipelineExecutionSummaries[?contains(sourceRevisions[].revisionId, '$REVISION_ID')]|[0]"

while true; do
  execution=$(aws codepipeline list-pipeline-executions --pipeline-name "$PIPELINE_NAME" --query "$query")

  if [[ $execution != null ]]; then
    [[ ${start:-} ]] || break
    [[ $start < $(date --date="$(jq --raw-output '.startTime' <<< "$execution")" +%s) ]] && break
  fi

  [[ ${timeout:-} ]] && elapsed=$((elapsed + 5)) && [[ $elapsed -gt $timeout ]] && unset execution && break
  echo -n "." && sleep 5
done

if [[ ${execution:-} ]]; then
  echo "execution-id=$(jq --raw-output '.pipelineExecutionId' <<< "$execution")" >> "$GITHUB_OUTPUT"
  exit
fi

echo "Pipeline \`$PIPELINE_NAME\` didn't start execution within the $TIMEOUT_MINUTES minute timeout" |
  tee "$GITHUB_STEP_SUMMARY" && exit 1
