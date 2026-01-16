# Mirror Repository to GitLab (SSH) — GitHub Action

A reusable Composite Action that mirrors a GitHub repository branch to a GitLab repo via SSH.

## Inputs

- `gitlab-ssh-private-key` (**required**)  
  SSH private key with write access to the GitLab repository (recommended: GitLab Deploy Key).

- `gitlab-ssh-remote` (**required**)  
  GitLab SSH remote, e.g. `git@gitlab.com:group/repo.git`

- `gitlab-ssh-host` (default: `gitlab.com`)
- `gitlab-ssh-port` (default: `22`)
- `source-branch` (default: `main`)
- `target-branch` (default: `main`)
- `strict-remote-check` (default: `true`)  
  When `true`, enforces the remote to start with `git@gitlab.com:`.

- `checkout` (default: `true`)
- `fetch-depth` (default: `0`)  
  `0` means full history (recommended for mirrors).

## Example usage

```yaml
name: Mirror Repository to GitLab

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  mirror:
    runs-on: ubuntu-latest
    steps:
      - name: Mirror to GitLab
        uses: vscoding/gitlab-mirror-action@v1
        with:
          gitlab-ssh-private-key: ${{ secrets.GITLAB_SSH_PRIVATE_KEY }}
          gitlab-ssh-remote: ${{ vars.GITLAB_SSH_REMOTE }}
          gitlab-ssh-host: ${{ vars.GITLAB_SSH_HOST }}
          gitlab-ssh-port: ${{ vars.GITLAB_SSH_PORT }}
          source-branch: main
          target-branch: main
```

## Notes

- This action pushes **only one branch** by default (`main -> main`).
- For GitLab self-hosted, set `gitlab-ssh-host` and disable strict check:
  - `strict-remote-check: "false"`
