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

case "$(basename "${SHELL:-sh}")" in
    zsh)
        rc_file="$HOME/.zshrc"
        ;;
    bash)
        rc_file="$HOME/.bashrc"
        ;;
    *)
        rc_file="$HOME/.profile"
        ;;
esac

mkdir -p "$(dirname "$rc_file")" || fail "could not prepare $(dirname "$rc_file")"
: >> "$rc_file" || fail "could not update $rc_file"
path_line='case ":$PATH:" in *:"$HOME/.local/bin":*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'
if ! grep -Fq "$path_line" "$rc_file"; then
    {
        printf '\n# Added by yas-gacp installer\n%s\n' "$path_line"
    } >> "$rc_file" || fail "could not update $rc_file"
    say "Added ~/.local/bin to PATH in $rc_file"
else
    say "PATH setup already exists in $rc_file"
fi

say 'Open a new terminal or run: . '"$rc_file"
say 'Then run: yas-gacp "your commit message"'
