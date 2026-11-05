# yas-gacp

A small Bash helper that stages all changes, creates a Git commit, and pushes the current branch. It prints a readable summary and explains common push failures.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/emyassine/gacp/main/install.sh | sh
```

The installer puts `yas-gacp` in `~/.local/bin` and adds that directory to the startup file for the current shell (`.bashrc`, `.zshrc`, or `.profile`). Open a new terminal, or source that file, then use:

```sh
yas-gacp "describe your changes"
```

Requires Bash and Git. The installer is a separate POSIX shell script; the `yas-gacp` command contains only the Git workflow.
