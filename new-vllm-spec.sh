#!/bin/sh

set -eu

show_help() {
    cat <<EOF
Usage: $0 [spec_name]

Start a new feature with spec-kit, using the passed-in spec name for
our git worktree, git branch, and name of the spec to be created.

This expects you to be in the main vllm repository to run.

It also assumes you have the vllm-spec-kit repo cloned as a sibling
directory to the vllm repo, and will fail if that is not the case.

Options:
  --help    Display this help message and exit.

Example:
  $0 003-my-new-spec
EOF
}

repo_name=$(basename "$(git rev-parse --show-toplevel)")
if [ "$repo_name" != "vllm" ]; then
    echo "Error: This can only be run from a clone of the vllm repository.\n" >&2
    show_help
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Error: No spec_name provided.\n" >&2
    show_help
    exit 1
fi

if [ $# -gt 1 ]; then
    echo "Error: Too many arguments provided.\n" >&2
    exit 1
fi

if [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

SPEC_NAME="$1"

git_common_dir=$(git rev-parse --git-common-dir)
git_dir=$(git rev-parse --git-dir)
if [ "$git_common_dir" != "$git_dir" ]; then
    # Inside a git working tree, so error out
    echo "Error: This cannot be run from inside an existing git worktree.\n" >&2
    show_help
    exit 1
fi

WORKTREE_DIR="trees/$SPEC_NAME"
echo "Creating new gitworktree $WORKTREE_DIR"
git worktree add -d $WORKTREE_DIR

echo "Symlinking .specify dir from vllm-spec-kit repo"
ln -s ../../../vllm-spec-kit/.specify $WORKTREE_DIR/.specify

echo "Symlinking specs dir from vllm-spec-kit repo"
ln -s ../../../vllm-spec-kit/specs $WORKTREE_DIR/specs

echo "Symlinking .claude dir from vllm-spec-kit repo"
ln -s ../../../vllm-spec-kit/.claude $WORKTREE_DIR/.claude

if [ -d "venv" ]; then
    echo "Symlinking venv from repo root"
    ln -s ../../venv $WORKTREE_DIR/venv
fi

if [ -d ".vscode" ]; then
    echo "Copying .vscode from repo root into worktree"
    cp -r .vscode $WORKTREE_DIR/.vscode/
fi

echo "New git worktree created at $WORKTREE_DIR!"
echo "To get started coding:"
echo "  cd $WORKTREE_DIR"
