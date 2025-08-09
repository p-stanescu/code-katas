#!/bin/bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "❌ Please provide one or more packages to audit and install."
  echo "👉 Usage: pnpm run safe-install <pkg[@version]> [pkg2 ...]"
  exit 1
fi

echo "✅ Arguments provided: $#"
echo "📋 Packages to process:"
for pkg in "$@"; do
  echo "  - $pkg"
done

echo ""

for pkg in "$@"; do
  echo "🔍 Auditing $pkg with npq..."
  if npq_output=$(echo "N" | npx npq "$pkg" 2>&1); then
    # Display the npq output but filter out the install prompt lines
    echo "$npq_output" | grep -v "Continue install" | grep -v "^N$"
    echo "✅ npq audit completed for $pkg"

    echo "🔍 Checking $pkg for typosquatting..."
    npx anti-typosquatting "$pkg" || { echo "❌ Typosquatting check failed for $pkg"; exit 1; }
    echo "✅ Typosquatting check completed for $pkg"

    read -rp "⚠️  Proceed to install $pkg? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "⏭️  Skipping $pkg"
      exit 1
    fi

    echo "📦 Installing $pkg via pnpm..."
    pnpm add "$pkg"
    echo "✅ Successfully installed $pkg"
    echo ""
    echo "🔍 Running post-install audit..."
    pnpm audit || echo "⚠️  Audit completed with issues. Please review."

    echo ""
    echo "🎉 Safe install process completed!"
  else
    echo "❌ npq audit failed for $pkg (security issues found or package doesn't exist)"
    echo "⏭️  Skipping $pkg"
    exit 0
  fi

done
