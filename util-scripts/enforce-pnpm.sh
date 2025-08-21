#!/bin/bash

USER_AGENT="${npm_config_user_agent:-}"

if [ -z "$USER_AGENT" ]; then
  printf "❌ Could not detect the package manager. Please use: pnpm install\n"
  exit 1
fi

if [[ "$USER_AGENT" != *"pnpm"* ]]; then
  printf "❌ Please use pnpm for this project (e.g. 'pnpm install')\n"

  if [ -d "node_modules" ]; then
    printf "→ Removing 'node_modules' created by mistake…\n"
    rm -rf node_modules
  fi

  if [ -f "package-lock.json" ]; then
    printf "→ Removing 'package-lock.json' created by mistake…\n"
    rm -f package-lock.json
  fi

  if [ -f "yarn.lock" ]; then
    printf "→ Removing 'yarn.lock' created by mistake…\n"
    rm -f yarn.lock
  fi

  exit 1
fi

exit 0
