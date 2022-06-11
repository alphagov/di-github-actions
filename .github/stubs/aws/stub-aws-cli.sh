set -eu

[[ ${1:-} == help ]] && echo "Using stub AWS CLI"

[[ ${1:-} == cloudformation && ${2:-} == describe-stacks ]] && cat "$(dirname "${BASH_SOURCE[0]}")/stacks.json"

exit 0
