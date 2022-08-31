cut_off_date=$(date -d "$THRESHOLD_DAYS days ago" +%Y-%m-%d)
echo "Cut off date: $cut_off_date"

failed_apps=()
deleted_apps=()
for app in $(cf apps | awk 'NR>3 {print $1}'); do
  last_upload_date=$(cf events "$app" | grep audit.app.package.upload | awk 'NR==1 {print $1}') || true
  echo "$app | last uploaded: $last_upload_date"

  if [[ -z $last_upload_date || $(date -d "$last_upload_date" +%Y-%m-%d) < $cut_off_date ]]; then
    cf delete "$app" -rf && deleted_apps+=("$app") || failed_apps+=("$app")
  fi
done

if [[ ${#deleted_apps[@]} -eq 1 ]]; then
  echo "Deleted app \`${deleted_apps[*]}\`" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#deleted_apps[@]} -gt 1 ]]; then
  echo "Deleted apps:" >> "$GITHUB_STEP_SUMMARY"
  for app in "${deleted_apps[@]}"; do
    echo "  - $app" >> "$GITHUB_STEP_SUMMARY"
  done
fi

if [[ ${#failed_apps[@]} -eq 1 ]]; then
  echo "Failed to delete app \`${failed_apps[*]}\`" >> "$GITHUB_STEP_SUMMARY"
elif [[ ${#failed_apps[@]} -gt 1 ]]; then
  echo "Failed to delete app:" >> "$GITHUB_STEP_SUMMARY"
  for app in "${failed_apps[@]}"; do
    echo "  - $app" >> "$GITHUB_STEP_SUMMARY"
  done
fi

[[ ${#failed_apps[@]} -gt 1 ]] && exit 1
