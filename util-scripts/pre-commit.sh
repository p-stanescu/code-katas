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
pnpm secrets:staged || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ Potential secrets detected! Commit blocked.\n"
  exit 1
fi
printf "✅ No secrets found.\n\n"

printf "🛡️ Dependency audit..."

pnpm audit || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ PNPM audit found vulnerabilities.\n"
  printf "💡 Run 'pnpm audit --fix' to automatically fix issues."
  exit 1
fi
printf "✅ Audit passed!\n\n"

printf "🧹 Linting..."

pnpm lint || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ Lint failed.\n"
  exit 1
fi
printf "✅ Lint passed!\n\n"

printf "📐 Type checking..."

pnpm typecheck || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ Type check failed.\n"
  exit 1
fi
printf "✅ Type check passed!\n\n"

printf "🎨 Format check..."

pnpm format:check || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ Format check failed.\n"
  exit 1
fi
printf "✅ Format check passed!\n\n"

printf "🔎 Running tests..."

pnpm test || exit_code=$?
if [ "$exit_code" ]; then
  printf "\n❌ Tests failed.\n"
  exit 1
fi
printf "✅ All tests passed!\n\n"

printf "🎉 All checks and tests successfully completed — commit ready!"
exit 0
