#!/bin/sh

if [ -f .env.local ]; then
  export $(grep -v '^#' .env.local | xargs)
fi

if [ "$SKIP_HOOKS" = "true" ]; then
  printf "🔁 SKIP_HOOKS is true — skipping pre-commit checks"
  exit 0
fi

printf "📋 Starting pre-commit checks...\n\n"

printf "🔐 Secret scan..."
gitleaks protect --staged --redact
if [ $? -ne 0 ]; then
  printf "❌ Potential secrets detected! Git commit blocked."
  exit 1
fi
printf "✅ No secrets found.\n\n"

printf "🛡️ Dependency audit..."

pnpm audit || exit_code=$?
if [ "$exit_code" ]; then
  printf "❌ PNPM audit found vulnerabilities."
  printf "💡 Run 'pnpm audit --fix' to automatically fix issues."
  exit 1
fi
printf "✅ Audit passed!\n\n"

printf "🧹 Linting..."

pnpm lint || exit_code=$?
if [ "$exit_code" ]; then
  echo "❌ Lint failed."
  exit 1
fi
printf "✅ Lint passed!\n\n"

printf "📐 Type checking..."

pnpm typecheck || exit_code=$?
if [ "$exit_code" ]; then
  printf "❌ Type check failed."
  exit 1
fi
printf "✅ Type check passed!\n\n"

printf "🎨 Format check..."

pnpm format:check || exit_code=$?
if [ "$exit_code" ]; then
  printf "❌ Format check failed."
  exit 1
fi
printf "✅ Format check passed!\n\n"

printf "🔎 Running tests..."

pnpm test || exit_code=$?
if [ "$exit_code" ]; then
  printf "❌ Tests failed."
  exit 1
fi
printf "✅ All tests passed!\n\n"

printf "🎉 All checks and tests successfully completed — commit ready!"
exit 0
