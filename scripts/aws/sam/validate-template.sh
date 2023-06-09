set -eu -o pipefail

: "${TEMPLATE:=template.yaml}" # The template to validate
: "${AWS_REGION:=eu-west-2}"   # The AWS region to use when validating

BASE_DIR="$(dirname "${BASH_SOURCE[0]}")"
REPORT="$BASE_DIR"/../../report-step-result/print-file.sh
OUTPUT="$RUNNER_TEMP"/validate.output
RESULTS="$RUNNER_TEMP"/validate.results

sam validate --template $TEMPLATE --region $AWS_REGION | tee "$OUTPUT" || cat "$OUTPUT" >> "$RESULTS"
sam validate --template $TEMPLATE --lint | tee "$OUTPUT" || cat "$OUTPUT" >> "$RESULTS"

[[ -s $RESULTS ]] || exit 0
FILE=$RESULTS TITLE="SAM validation" LANGUAGE=shell CODE_BLOCK=true $REPORT >> "$GITHUB_STEP_SUMMARY" && exit 1
