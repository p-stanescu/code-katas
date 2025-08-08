#!/bin/bash
set -euo pipefail

# Step 1: Argument validation
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

# Step 2: Install Socket CLI if not available
if ! command -v socket &> /dev/null; then
  echo "📦 Socket CLI not found. Installing..."
  pnpm add -D @socketsecurity/cli
  echo "✅ Socket CLI installed successfully"
fi

# Step 3: Security audit with Socket
for pkg in "$@"; do
  echo "🔍 Auditing $pkg with Socket..."

  # Use Socket to audit the package before installation
  if socket npm view "$pkg"; then
    echo "✅ Socket audit completed for $pkg"

    echo ""
    read -rp "⚠️  Proceed to install $pkg? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "⏭️  Skipping $pkg"
      continue
    fi

    echo "📦 Installing $pkg via pnpm..."
    pnpm add "$pkg"
    echo "✅ Successfully installed $pkg"
  else
    echo "❌ Socket audit failed for $pkg (security issues found or package doesn't exist)"
    echo "⏭️  Skipping $pkg"
    continue
  fi

  echo ""
done

echo ""
echo "🔍 Running post-install audit..."
pnpm audit || echo "⚠️  Audit completed with issues. Please review."

echo ""
echo "🎉 Safe install process completed!"
