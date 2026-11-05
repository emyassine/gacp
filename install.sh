#!/bin/sh
# Install yas-gacp. Runtime behavior lives in the separate yas-gacp script.
set -eu

REPOSITORY='https://github.com/emyassine/gacp'
RAW_BASE='https://raw.githubusercontent.com/emyassine/gacp/main'
INSTALL_DIR="${YAS_GACP_INSTALL_DIR:-$HOME/.local/bin}"
DEST="$INSTALL_DIR/yas-gacp"

say() { printf '%s\n' "yas-gacp installer: $*"; }
fail() { say "Error: $*" >&2; exit 1; }

mkdir -p "$INSTALL_DIR" || fail "could not create $INSTALL_DIR"
tmp_file=$(mktemp "${TMPDIR:-/tmp}/yas-gacp.XXXXXX") || fail 'could not create a temporary file'
trap 'rm -f "$tmp_file"' EXIT HUP INT TERM

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_BASE/yas-gacp" -o "$tmp_file" || fail 'download failed; check the repository URL and your connection'
elif command -v wget >/dev/null 2>&1; then
    wget -q "$RAW_BASE/yas-gacp" -O "$tmp_file" || fail 'download failed; check the repository URL and your connection'
else
    fail 'curl or wget is required'
fi

[ -s "$tmp_file" ] || fail 'downloaded command is empty'
install -m 0755 "$tmp_file" "$DEST" || fail "could not install to $DEST"
say "Installed $DEST"

shell_name=$(basename "${SHELL:-sh}")
path_line='case ":$PATH:" in *:"$HOME/.local/bin":*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'

add_path_setup() {
    target=$1
    mkdir -p "$(dirname "$target")" || fail "could not prepare $(dirname "$target")"
    : >> "$target" || fail "could not update $target"
    if ! grep -Fq "$path_line" "$target"; then
        {
            printf '\n# Added by yas-gacp installer\n%s\n' "$path_line"
        } >> "$target" || fail "could not update $target"
        say "Added ~/.local/bin to PATH in $target"
    else
        say "PATH setup already exists in $target"
    fi
}

case "$shell_name" in
    zsh)
        add_path_setup "$HOME/.zshrc"
        reload_hint='. "$HOME/.zshrc"'
        ;;
    bash)
        add_path_setup "$HOME/.bashrc"
        # macOS Terminal commonly starts login Bash, which reads .bash_profile.
        if [ "$(uname -s 2>/dev/null || true)" = Darwin ] || [ -f "$HOME/.bash_profile" ]; then
            add_path_setup "$HOME/.bash_profile"
            reload_hint='. "$HOME/.bash_profile"'
        else
            reload_hint='. "$HOME/.bashrc"'
        fi
        ;;
    *)
        add_path_setup "$HOME/.profile"
        reload_hint='. "$HOME/.profile"'
        ;;
esac

say "Open a new terminal or run: $reload_hint"
say 'Then run: yas-gacp "your commit message"'
