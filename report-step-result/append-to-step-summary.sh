set -eu

file=${FILE_PATH}
message=${TITLE}
language=${LANGUAGE}
output_file=${OUT_FILE:-$GITHUB_STEP_SUMMARY}

use_code_block=false
[[ ${CODE_BLOCK} == true ]] && use_code_block=true

{
  [[ $message ]] && echo "**$message**"
  $use_code_block && echo '```'"$language"
  cat "$file"
  $use_code_block && echo '```'
} >> "$output_file"

echo "The result has been written to ${OUT_FILE:-the job summary}"
