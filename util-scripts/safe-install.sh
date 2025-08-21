#!/usr/bin/env bash
# safe-install.sh — step 0.6

set -euo pipefail

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

# -------------- Input validation ----------------

if [ "$#" -ne 1 ]; then
  printf "❌ Exactly one dependency must be provided.\n\n"
  printf "⚠️ Usage: pnpm run safe-install <dependency_package>\n\n"
  exit 1
fi

dependency_package="$1"

printf "📦 Preparing to validate and install: %s\n" "$dependency_package"

# --------------// Package verification \\----------------

if ! resolved_version="$(pnpm view "$dependency_package" version)"; then
  printf "❌ Could not find '%s' in the npm registry (see error above).\n\n" "$dependency_package"
  exit 1
fi

printf "✅ Found '%s' (latest version: %s)\n\n" "$dependency_package" "$resolved_version"

# --------------// Package metadata \\----------------

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

# --------------// Security scanning \\----------------

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
