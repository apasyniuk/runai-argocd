#!/usr/bin/env bash
set -euo pipefail

# Usage: ./bump-versions.sh [patch|minor|major]
# Bumps the version field in every charts/*/Chart.yaml.

PART="${1:-patch}"

bump() {
  local version="$1"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"
  case "$PART" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    *)
      echo "Unknown part '$PART'. Use patch, minor, or major." >&2
      exit 1
      ;;
  esac
}

for chart in charts/*/Chart.yaml; do
  current="$(grep '^version:' "$chart" | awk '{print $2}')"
  new="$(bump "$current")"
  sed -i "s/^version: .*/version: ${new}/" "$chart"
  echo "$(dirname "$chart"): ${current} → ${new}"
done
