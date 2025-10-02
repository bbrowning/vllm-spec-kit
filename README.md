# vllm-spec-kit

My files for working with spec-kit and vLLM.

## vLLM development workflow with Claude and spec-kit

This workflow uses a single shared vllm-spec-kit directory to hold `.claude`, `.specify`, and `specs` directories that will be shared across multiple vLLM worktrees, with one worktree per AI-assisted feature being developed. The downside of this workflow is it's up to me to manually manage the vllm-spec-kit git repo, such as to commit and push specs as they change. The upside is it keeps all of the spec-kit artifacts out of the PRs opened to vLLM so that they are clean.

### Initial setup

Clone this repository.

```
cd ~/src
git clone git@github.com:bbrowning/vllm-spec-kit.git
```

### Starting a new feature / bugfix


There is a helper script in `new-vllm-spec.sh` I use to setup a new git worktree, vllm branch for the feature / bugfix work, symlink needed directories, and copy my vscode settings.json into the new worktree.
Setup a new git worktree and claude/spec-kit symlinks. The basename of the worktree (ie last path part) will become the name of the git branch created when we use `/specify` in spec-kit.

**Note:** This assumes an already setup ~/src/vllm for dev use, such as `pip install -e .` and anything else required to get your base vllm repository setup for development.

```
cd ~/src/vllm

# Ensure the right upstream base branch is used, if not main
git checkout main
git pull

../vllm-spec-kit/new-vllm-spec.sh 002-my-new-feature
```

Start claude in the new git worktree:

```
cd trees/002-my-new-feature
source venv/bin/activate
claude
```

Start specifying the new bugfix/feature:

```
/specify Here's my cool thing I need to do.
```

When happy with the specs, plans, tasks, etc commit and push to vllm-spec-kit. Those specs can then be referenced in any PRs opened upstream in vLLM by linking to them in the pushed vllm-spec-kit repo.

### Cleaning up old git worktrees after features merge

Because we have some untracked files in the worktree, we have to `--force` when removing the worktree. Be sure you're finished with that worktree before doing this.

```
cd ~/src/vllm
git worktree list
git worktree remove 002-my-new-feature --force
git branch -D 002-my-new-feature
```

## spec-kit customizations

### BRANCH_NAME from git worktree basename

I didn't like how spec-kit named git branches and specs by default, so instead I choose this by what I name my git worktree and adjusted `.specify/scripts/bash/create-new-feature.sh` to use the basename of the gitworktree if in one.
