#!/usr/bin/env bash
# safe-install.sh — step 0.3

set -euo pipefail

# Check that exactly ONE argument is given
if [ "$#" -ne 1 ]; then
  printf "❌ Exactly one dependency must be provided.\n\n"
  printf "⚠️ Usage: pnpm run safe-install <dependency_package>\n\n"
  exit 1
fi

dependency_package="$1"

printf "📦 Preparing to validate and install: %s\n" "$dependency_package"

# Check the package exists and capture the latest version
if ! resolved_version="$(pnpm view "$dependency_package" version --json)"; then
  printf "❌ Could not find '%s' in the npm registry (see error above).\n\n" "$dependency_package"
  exit 1
fi

printf "✅ Found '%s' (latest version: %s)\n\n" "$dependency_package" "$resolved_version"
