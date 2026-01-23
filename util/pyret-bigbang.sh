#!/bin/zsh

# Historical: Initialize the pyret monorepo by pulling each subrepo into its
# own branch, moving its files into a subdirectory, tagging the import, then
# merging all branches into main.

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

pull_subrepo() {
    local branch="$1"
    local repo="$2"
    branch="$1"
    repo="$2"

    git branch "$branch"
    git checkout "$branch"
    git pull --allow-unrelated-histories --no-ff "$repo"

    mkdir "$branch"
    git mv $(git ls-tree --name-only "$branch") "$branch"
    git commit -m "move $branch files into $branch"
    git checkout main
}


git init
git commit --allow-empty -m "Initial commit"

for branch in "${(@k)repos}"; do
  echo "$branch" "${repos[$branch]}"
  pull_subrepo "$branch" "${repos[$branch]}"
  git tag -a "repo-$branch" "$branch" -m "Moving ${repos[$branch]} into monorepo as $branch/"
done

for branch in "${(@k)repos}"; do
  git merge "$branch"
done
