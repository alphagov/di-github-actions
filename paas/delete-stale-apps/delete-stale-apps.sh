set -eu

deleted_apps=()
failed_apps=()

cut_off_date=$(date -d "$THRESHOLD_DAYS days ago" +%Y-%m-%d)
echo "Cut off date: $cut_off_date"

for app in $(cf apps | awk 'NR>3 {print $1}'); do
  last_upload_date=$(cf events "$app" | grep audit.app.package.upload | awk 'NR==1 {print $1}') || true
  echo "$app | last uploaded: $last_upload_date"

  if [[ -z $last_upload_date || $(date -d "$last_upload_date" +%Y-%m-%d) < $cut_off_date ]]; then
    cf delete "$app" -rf && deleted_apps+=("$app") || failed_apps+=("$app")
  fi
done

echo "deleted-apps=${deleted_apps[*]}" >> "$GITHUB_OUTPUT"
echo "failed-apps=${failed_apps[*]}" >> "$GITHUB_OUTPUT"

[[ ${#failed_apps[@]} -eq 0 ]] || exit 1
