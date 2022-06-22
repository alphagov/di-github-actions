set -eu

stacks_file=${DELETED_STACKS_FILE:-}

if [[ ${1:-} == delete ]]; then
  while [[ ${2:-} ]]; do
    case $2 in
    --stack-name)
      shift
      stack_name=$2
      ;;
    --region)
      shift
      region=$2
      ;;
    esac
    shift
  done

  echo "Deleted stack $stack_name in region $region"

  deleted_stacks=()
  if [[ $stacks_file ]]; then
    touch "$stacks_file"
    mapfile -t deleted_stacks < "$stacks_file"
    echo "$stack_name" >> deleted_stacks
  fi

  deleted_stacks+=("$stack_name")
  echo "DELETED_STACKS=${deleted_stacks[*]}" >> "$GITHUB_ENV"
  echo "DELETED_STACKS_REGION=$region" >> "$GITHUB_ENV"
  exit 0
fi

echo "Unknown command: $*"
exit 1
