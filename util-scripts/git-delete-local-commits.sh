#!/bin/sh

prompt() {
  printf "%s" "$1"
  IFS= read -r REPLY
}

fail() {
  printf "❌ %s\n" "$1" >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "Not a Git repository."

prompt "🎯 Enter the commit hash you want to DELETE COMPLETELY: "
commit_hash=$REPLY

if ! git cat-file -e "$commit_hash" 2>/dev/null; then
  fail "Commit '$commit_hash' not found in this repository."
fi

subject=$(git log -1 --pretty=%s "$commit_hash" 2>/dev/null)

printf "\n⚠️  You have chosen commit: %s — %s\n" "$commit_hash" "$subject"
printf "\nThis will:\n"
printf "  • Make the commit unreachable (ensure you've reset/removed refs first)\n"
printf "  • Expire reflogs immediately\n"
printf "  • Run git's garbage collection to prune the commit data\n"
printf "\nOnce done, this commit will be permanently gone from your local repo. This will not erase it from Github, if the commit was pushed to Github.\n"

prompt "\n❓ Do you really want to DELETE this commit? Type 'yes' to continue: "
[ "$REPLY" = "yes" ] || { printf "👍 Aborted. Nothing done.\n"; exit 0; }

cmds="
git reflog expire --expire-unreachable=now --all
git gc --prune=now --aggressive
"

printf "\n🧪 The following commands will be run:\n$cmds\n"

prompt "\n❓ Execute these commands now? Type 'yes' to proceed: "
if [ "$REPLY" = "yes" ]; then
  sh -c "$cmds"
  printf "✅ Commit deletion process complete.\n"
else
  printf "👍 Skipped. No changes made.\n"
fi
