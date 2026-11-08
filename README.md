# yas-gacp

A small Bash helper that stages all changes, creates a Git commit, and pushes the current branch. It prints a readable summary, explains common push failures, and shows how to merge a feature branch into `main` when the push is complete.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/emyassine/gacp/main/install.sh | sh
```

The installer puts `yas-gacp` in `~/.local/bin` and adds that directory to the startup file for the current shell (`.bashrc`, `.zshrc`, or `.profile`). Open a new terminal, or source that file, then use:

```sh
yas-gacp "describe your changes"
```

## Commands

```sh
yas-gacp "describe your changes"  # stage, commit, and push the current branch
yas-gacp --version                # print the installed version
yas-gacp --update                 # update from the repository's main branch
yas-gacp --help                   # show usage
```

`--version` prints the semantic version, human-readable edition, and release date/time. `--update` downloads and validates the latest script. If it is already identical to the installed copy, it says so and leaves the file untouched; otherwise it reports the old and new versions, install path, and release notes.

When the current branch differs from `main`, the completion message prints the commands to merge it into `main`, plus a prompt you can give Codex to perform the merge.

Requires Bash and Git. `curl` or `wget` is needed for installation and self-update. The installer is a separate POSIX shell script.
