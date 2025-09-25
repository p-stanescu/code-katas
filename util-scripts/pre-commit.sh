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
pnpm secrets:staged
if [ $? -ne 0 ]; then
  printf "\n❌ Potential secrets detected! Commit blocked.\n"
  exit 1
fi
printf "✅ No secrets found.\n\n"

printf "🛡️ Dependency audit..."

pnpm audit
if [ $? -ne 0 ]; then
  printf "\n❌ PNPM audit found vulnerabilities.\n"
  printf "💡 Run 'pnpm audit --fix' to automatically fix issues."
  exit 1
fi
printf "✅ Audit passed!\n\n"

printf "🧹 Linting..."

pnpm lint
if [ $? -ne 0 ]; then
  printf "\n❌ Lint failed.\n"
  exit 1
fi
printf "✅ Lint passed!\n\n"

printf "📐 Type checking..."

pnpm typecheck
if [ $? -ne 0 ]; then
  printf "\n❌ Type check failed.\n"
  exit 1
fi
printf "✅ Type check passed!\n\n"

printf "🎨 Format check..."

pnpm format:check
if [ $? -ne 0 ]; then
  printf "\n❌ Format check failed.\n"
  exit 1
fi
printf "✅ Format check passed!\n\n"

printf "🔎 Running tests..."

pnpm test:ci:coverage
if [ $? -ne 0 ]; then
  printf "\n❌ Tests failed.\n"
  exit 1
fi
printf "✅ All tests passed!\n\n"

printf "🎉 All checks and tests successfully completed — commit ready!"
exit 0
