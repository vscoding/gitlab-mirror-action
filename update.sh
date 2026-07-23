#!/usr/bin/env bash

set -Eeuo pipefail

readonly REMOTE="origin"
readonly TAG="v1"
readonly DEFAULT_COMMIT_MESSAGE="Update GitHub Action"

if (( $# > 1 )); then
  printf 'Usage: %s [commit-message]\n' "${0##*/}" >&2
  exit 2
fi

commit_message="${1:-$DEFAULT_COMMIT_MESSAGE}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Error: this script must be run inside a Git repository.\n' >&2
  exit 1
fi

if ! branch="$(git symbolic-ref --quiet --short HEAD)"; then
  printf 'Error: cannot update %s from a detached HEAD.\n' "$TAG" >&2
  exit 1
fi

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  printf 'Error: Git remote "%s" does not exist.\n' "$REMOTE" >&2
  exit 1
fi

unmerged="$(git ls-files --unmerged)"
if [[ -n "$unmerged" ]]; then
  printf 'Error: resolve merge conflicts before running this script.\n' >&2
  exit 1
fi

changes="$(git status --porcelain --untracked-files=normal)"
if [[ -z "$changes" ]]; then
  printf 'No changes detected; nothing to update.\n'
  exit 0
fi

git var GIT_AUTHOR_IDENT >/dev/null

printf 'Committing changes on branch "%s"...\n' "$branch"
git add -A
git commit -m "$commit_message"

printf 'Pushing branch "%s" to "%s"...\n' "$branch" "$REMOTE"
git push "$REMOTE" "HEAD:refs/heads/$branch"

printf 'Replacing remote tag "%s"...\n' "$TAG"
if git ls-remote --exit-code --tags "$REMOTE" "refs/tags/$TAG" >/dev/null 2>&1; then
  git push "$REMOTE" ":refs/tags/$TAG"
else
  status=$?
  if (( status != 2 )); then
    printf 'Error: failed to inspect remote tag "%s".\n' "$TAG" >&2
    exit "$status"
  fi
fi

git tag --force "$TAG" HEAD
git push "$REMOTE" "refs/tags/$TAG:refs/tags/$TAG"

printf 'Updated "%s" and tag "%s" to %s.\n' \
  "$branch" "$TAG" "$(git rev-parse --short HEAD)"
