#!/bin/sh

if [ -f .env.local ]; then
  export $(grep -v '^#' .env.local | xargs)
fi

if [ "$SKIP_HOOKS" = "true" ]; then
  echo "🔁 SKIP_HOOKS is true — skipping pre-commit checks"
  exit 0
fi

printf "📋 Starting pre-commit checks...\n\n"

printf "🛡️ Dependency audit..."
pnpm audit || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ PNPM audit found vulnerabilities."
  echo "💡 Run 'pnpm audit --fix' to automatically fix issues."
  exit 1
fi
printf "✅ Audit passed!\n\n"

echo "🧹 Linting..."
pnpm lint || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ Lint failed."
  exit 1
fi
printf "✅ Lint passed!\n\n"

echo "📐 Type checking..."
pnpm typecheck || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ Type check failed."
  exit 1
fi
printf "✅ Type check passed!\n\n"

echo "🎨 Format check..."
pnpm format:check || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ Format check failed."
  exit 1
fi
printf "✅ Format check passed!\n\n"

echo "🔎 Running tests..."
pnpm test || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ Tests failed."
  exit 1
fi
printf "✅ All tests passed!\n\n"

echo "🎉 All checks completed — commit ready!"
exit 0
