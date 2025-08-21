#!/usr/bin/env bash
# safe-install.sh — step 0.6

set -euo pipefail

# Ask the user to confirm (default = No)
confirm() {
  question="$1"
  printf "%s [y/N] " "$question"
  read -r reply

  if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
    return 0
  else
    printf "⏭️  Cancelled.\n\n"
    exit 0
  fi
}

# Check that exactly one package is given
if [ "$#" -ne 1 ]; then
  printf "❌ Exactly one dependency must be provided.\n\n"
  printf "⚠️ Usage: pnpm run safe-install <dependency_package>\n\n"
  exit 1
fi

dependency_package="$1"

printf "📦 Preparing to validate and install: %s\n" "$dependency_package"

# Check the package exists and capture the latest version
if ! resolved_version="$(pnpm view "$dependency_package" version)"; then
  printf "❌ Could not find '%s' in the npm registry (see error above).\n\n" "$dependency_package"
  exit 1
fi

printf "✅ Found '%s' (latest version: %s)\n\n" "$dependency_package" "$resolved_version"

# Show some basic metadata
description="$(pnpm view "$dependency_package" description || echo "N/A")"
license="$(pnpm view "$dependency_package" license || echo "N/A")"
homepage="$(pnpm view "$dependency_package" homepage || echo "N/A")"
repository="$(pnpm view "$dependency_package" repository.url || pnpm view "$dependency_package" repository || echo "N/A")"
maintainers="$(pnpm view "$dependency_package" maintainers || echo "N/A")"

printf "Description: %s\n" "$description"
printf "License: %s\n" "$license"
printf "Homepage: %s\n" "$homepage"
printf "Repository: %s\n" "$repository"
printf "Maintainers: %s\n\n" "$maintainers"

# Run OSV scan via a repo-local temp folder
tmpdir="./.tmp-scan"
mkdir -p "$tmpdir"

printf '{ "name": "tmp-scan", "private": true }' > "$tmpdir/package.json"

(
  cd "$tmpdir"
  pnpm add --lockfile-only --ignore-scripts --silent "${dependency_package}@${resolved_version}" || true

  printf "🔍 Running security check with osv-scanner…\n\n"
  osv-scanner --format table --lockfile pnpm-lock.yaml || true
)

rm -rf "$tmpdir"

printf "✅ osv-scanner check finished.\n\n"
