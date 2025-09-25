#!/usr/bin/env bash

set -euo pipefail

confirm() {
  printf "%s [y/N] " "$1"
  read -r reply
  if [ "$reply" = "y" ] || [ "$reply" = "Y" ]; then
    return 0
  else
    printf "⏭️  Cancelled.\n\n"
    exit 0
  fi
}

# -------------- Input validation ----------------

if [ "$#" -ne 1 ]; then
  printf "❌ Exactly one dependency must be provided.\n\n"
  printf "⚠️ Usage: pnpm run safe-install <dependency_package>\n\n"
  exit 1
fi

dependency_package="$1"

printf "📦 Preparing to validate and install: %s\n" "$dependency_package"

# --------------// Package verification \\----------------

resolved_version="$(pnpm view "$dependency_package" version)"
if [ $? -eq 0 ]; then
  printf "✅ Found '%s' (latest version: %s)\n\n" "$dependency_package" "$resolved_version"
else
  printf "❌ Could not find '%s' in the npm registry (see error above).\n\n" "$dependency_package"
  exit 1
fi

# --------------// Display package metadata \\----------------

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

# --------------// Security scanning (OSV API) \\----------------

printf "🔍 Checking OSV for %s@%s…\n\n" "$dependency_package" "$resolved_version"

osv_response="$(curl -s -H 'Content-Type: application/json' \
  -d "{\"package\": {\"ecosystem\": \"npm\", \"name\": \"$dependency_package\"}, \"version\": \"$resolved_version\"}" \
  https://api.osv.dev/v1/query)"

if [ "$osv_response" = "{}" ]; then
  printf "✅ No known vulnerabilities found by OSV.\n\n"
else
  printf "⚠️  Vulnerabilities reported by OSV for %s@%s:\n\n" "$dependency_package" "$resolved_version"
  printf "%s\n\n" "$osv_response"
fi

# --------------// Package installation \\----------------

confirm "Proceed with installation of '$dependency_package'?"

printf "Allow lifecycle scripts (preinstall/install/postinstall/prepare) to run? [y/N] "
read -r allow_scripts

if [ "$allow_scripts" = "n" ] || [ "$allow_scripts" = "N" ]; then
  scripts_flag="--ignore-scripts"
elif [ "$allow_scripts" = "y" ] || [ "$allow_scripts" = "Y" ]; then
  scripts_flag=""
else
  printf "❌ Invalid choice. Please answer y or n.\n"
  exit 1
fi

printf "Install as a devDependency? [y/N] "
read -r dev_dep

if [ "$dev_dep" = "y" ] || [ "$dev_dep" = "Y" ]; then
  dep_flag="--save-dev"
elif [ "$dev_dep" = "n" ] || [ "$dev_dep" = "N" ] || [ -z "$dev_dep" ]; then
  dep_flag=""
else
  printf "❌ Invalid choice. Please answer y or n.\n"
  exit 1
fi

printf "📦 Installing %s@%s…\n\n" "$dependency_package" "$resolved_version"
pnpm add $scripts_flag $dep_flag "${dependency_package}@${resolved_version}"
printf "✅ Installed %s@%s\n\n" "$dependency_package" "$resolved_version"

printf "🔍 Running pnpm audit…\n\n"
pnpm audit || printf "⚠️  Audit reported issues. Please review above.\n"
