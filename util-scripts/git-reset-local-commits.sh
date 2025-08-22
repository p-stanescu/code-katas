#!/bin/sh


repo_root=$(git rev-parse --show-toplevel 2>/dev/null || printf "UNKNOWN")
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || printf "DETACHED/UNKNOWN")
head_hash=$(git rev-parse --short=12 HEAD 2>/dev/null || printf "UNKNOWN")
head_subject=$(git log -1 --pretty=%s 2>/dev/null || printf "No commits or not a repo")

printf "📦 Repo: %s\n" "$repo_root"
printf "🌿 Branch: %s\n" "$current_branch"
printf "🔗 HEAD: %s — %s\n" "$head_hash" "$head_subject"

printf "\n ⚠️ This tool will run destructive Git actions.\n"
printf "   Proceed to the next step? (type 'yes' to continue): "
read ans
if [ "$ans" != "yes" ]; then
  printf "👍 Aborted. No changes made.\n"
  exit 0
fi

printf "✅ Context loaded. Ready to add the action menu next...\n"


prompt() {
  printf "%s" "$1"
  IFS= read -r REPLY
}

resolve_target_commit() {
  attempts=0
  max_attempts=3
  while [ $attempts -lt $max_attempts ]; do
    prompt "🎯 Target commit — type 'latest' for HEAD or enter a ref/sha (e.g. HEAD~1, abc123): "
    input=$REPLY

    [ -z "$input" ] && input="latest"
    [ "$input" = "latest" ] && input="HEAD"

    if sha=$(git rev-parse --verify --quiet "${input}^{commit}"); then
      sha_short=$(git rev-parse --short=12 "$sha")
      subject=$(git log -1 --pretty=%s "$sha" 2>/dev/null)
      printf "✅ Using %s — %s\n" "$sha_short" "$subject"
      TARGET_COMMIT="$sha"
      TARGET_COMMIT_SHORT="$sha_short"
      TARGET_SUBJECT="$subject"
      return 0
    fi

    attempts=$((attempts + 1))
    printf "❌ '%s' is not a valid commit/ref. (%d/%d attempts)\n" "$input" "$attempts" "$max_attempts"
  done

  printf "🚫 Too many invalid attempts. Aborting.\n"
  exit 1
}

confirm() {
  printf "⚠️ Execute this action? Type 'yes' to proceed: "
  IFS= read -r reply
  [ "$reply" = "yes" ]
}

run_git() {
  printf "▶️  Running: %s\n" "$1"
  # shellcheck disable=SC2086
  sh -c "$1"
  status=$?
  if [ $status -ne 0 ]; then
    printf "❌ Command failed (exit %d)\n" "$status"
    exit $status
  fi
  printf "✅ Done.\n"
}

# Menu loop
while :; do
  cat <<'MENU'

=============== Actions ===============
1) Show the hash/subject of the target commit
2) SOFT reset to the target (no files changed)
3) MIXED reset to the target (unstage changes)
4) HARD reset to the target (discard working tree/index)
5) Delete the *latest* commit locally (hard reset to HEAD~1)
q) Quit
=======================================
MENU

  prompt "Choose an option: "
  choice=$REPLY

  case "$choice" in
    1|2|3|4)
      resolve_target_commit
      ;;
    5)
      # For option 5 we always operate on latest commit (HEAD)
      TARGET_COMMIT=$(git rev-parse --verify --quiet HEAD) || {
        printf "❌ Cannot resolve HEAD.\n"; exit 1;
      }
      TARGET_COMMIT_SHORT=$(git rev-parse --short=12 "$TARGET_COMMIT")
      TARGET_SUBJECT=$(git log -1 --pretty=%s HEAD 2>/dev/null)
      ;;
    q|Q)
      printf "👋 Bye. No changes made.\n"
      exit 0
      ;;
    *)
      printf "❓ Invalid choice. Try again.\n"
      continue
      ;;
  esac

  # Build the command for the selected option
  cmd=""
  case "$choice" in
    1)
      printf "🔎 Target commit: %s — %s\n\n" "$TARGET_COMMIT_SHORT" "$TARGET_SUBJECT"
      continue
      ;;
    2)
      cmd="git reset --soft $TARGET_COMMIT"
      ;;
    3)
      cmd="git reset --mixed $TARGET_COMMIT"
      ;;
    4)
      cmd="git reset --hard $TARGET_COMMIT"
      ;;
    5)
      cmd="git reset --hard HEAD~1"
      ;;
  esac

  # Preview + confirmation + execution
  printf "🧪 Would run: %s\n" "$cmd"
  if confirm; then
    run_git "$cmd"
    # Show new HEAD after operations that move it
    new_head=$(git rev-parse --short=12 HEAD 2>/dev/null || printf "UNKNOWN")
    new_subj=$(git log -1 --pretty=%s 2>/dev/null || printf "No commits")
    printf "🔗 Now at HEAD: %s — %s\n\n" "$new_head" "$new_subj"
  else
    printf "👍 Skipped.\n\n"
  fi
done
