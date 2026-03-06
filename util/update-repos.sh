#!/bin/zsh

# For each subrepo branch, pulls in any new commits from the upstream remote.
# Then merges any updated branches back into the current branch.

typeset -A repos=(
  ["embed"]="git@github.com:jpolitz/pyret-embed.git"
  ["vscode"]="git@github.com:jpolitz/pyret-parley-vscode.git"
  ["npm"]="git@github.com:brownplt/pyret-npm.git"
  ["pyret.org"]="git@github.com:brownplt/pyret.org.git"
  ["docs"]="git@github.com:brownplt/pyret-docs.git"
  ["codemirror-mode"]="git@github.com:brownplt/pyret-codemirror-mode.git"
  ["code.pyret.org"]="git@github.com:brownplt/code.pyret.org.git"
  ["lang"]="git@github.com:brownplt/pyret-lang.git"
)

set -e

start_branch=$(git rev-parse --abbrev-ref HEAD)
updated=()

# Return to the starting branch on exit (covers both success and error paths).
# If a merge conflict left us in MERGING state, abort it first so checkout works.
cleanup() {
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
  if [[ -f "$git_dir/MERGE_HEAD" ]]; then
    echo "Aborting in-progress merge..."
    git merge --abort
  fi
  git checkout "$start_branch"
}
trap cleanup EXIT

for branch in "${(@k)repos}"; do
  upstream="${repos[$branch]}"
  git checkout "$branch"
  before=$(git rev-parse HEAD)

  echo "==> Checking $branch ($upstream)"
  git pull --no-ff "$upstream"

  after=$(git rev-parse HEAD)
  updated+=("$branch")
done

# Back to start before merging (trap will fire on EXIT but we do it explicitly
# here so the merges happen on the right branch)
trap - EXIT
git checkout "$start_branch"

echo ""
echo "==> Merging updated branches: ${updated[*]}"
for branch in "${updated[@]}"; do
  git merge --no-ff "$branch" -m "Merge branch '$branch'"
done

echo ""
echo "Done."
