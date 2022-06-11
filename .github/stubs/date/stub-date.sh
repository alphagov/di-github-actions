set -eu

date() {
  /usr/bin/date "$@"
}

today=${DATE_OVERRIDE:-$(date)}

args=()
while [[ ${1:-} ]]; do
  case $1 in
  -d | --date)
    shift
    date_arg=$1
    ;;
  *)
    args+=("$1")
    ;;
  esac
  shift
done

if [[ ${date_arg:-} ]]; then
  if [[ $date_arg =~ ([0-9]+)( days ago) ]]; then
    days=${BASH_REMATCH[1]}
    date -d "$(date -d "$today") - $days days" "${args[@]}"
  else
    date -d "$date_arg" "${args[@]}"
  fi
  exit
fi

date "${args[@]}"
