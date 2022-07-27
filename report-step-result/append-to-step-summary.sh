set -eu

file=${FILE_PATH}
output_file=${OUT_FILE:-$GITHUB_STEP_SUMMARY}
message=${TITLE}
language=${LANGUAGE}
use_code_block=${CODE_BLOCK}
fail_if_missing=${FAIL_IF_FILE_MISSING}

if ! [[ -f $file ]]; then
  echo "::warning title=Report missing::File $file has not been found"
  $fail_if_missing && exit 1 || exit 0
fi

{
  [[ $message ]] && echo "**$message**"
  $use_code_block && echo '```'"$language"
  cat "$file"
  $use_code_block && echo '```'
} >> "$output_file"

echo "The result has been written to ${OUT_FILE:-the job summary}"
