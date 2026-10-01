#!/bin/bash
# Installs the HyperFrames plugin pinned to v0.8.106 and replaces its Git LFS
# pointer files with real content. Runs only in Claude Code cloud sessions.
#
# Why the LFS step: Claude Code clones plugin marketplaces without LFS content,
# and the session git proxy refuses LFS batch requests for repos that are not
# attached to the session. GitHub serves public LFS objects over plain HTTPS at
# media.githubusercontent.com, so each file is fetched there and checked
# against the sha256 in its pointer.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PLUGIN="hyperframes@hyperframes"
MARKETPLACE="hyperframes"
REPO="heygen-com/hyperframes"
TAG="v0.8.106"
VERSION="0.8.106"
TAG_SHA="89704189d899cebf738a0e6e35f18fd7394b52a0"
JOBS="${HYPERFRAMES_LFS_JOBS:-8}"

PLUGINS_DIR="$HOME/.claude/plugins"
INSTALLED_JSON="$PLUGINS_DIR/installed_plugins.json"
MARKET_DIR="$PLUGINS_DIR/marketplaces/$MARKETPLACE"
LFS_HEADER="^version https://git-lfs.github.com/spec/v1"

log() { echo "[hyperframes-setup] $*" >&2; }

# Prints "<version> <commit sha> <install path>" for the installed plugin, or nothing.
installed_info() {
  [ -f "$INSTALLED_JSON" ] || return 0
  python3 - "$INSTALLED_JSON" "$PLUGIN" <<'PY'
import json, sys
entries = json.load(open(sys.argv[1])).get("plugins", {}).get(sys.argv[2], [])
for e in entries:
    print(e.get("version", ""), e.get("gitCommitSha", ""), e.get("installPath", ""))
    break
PY
}

if ! command -v claude >/dev/null 2>&1; then
  log "claude CLI not found on PATH"
  exit 1
fi

read -r cur_version cur_sha install_path <<<"$(installed_info)" || true

# Install the pinned release unless it is already there.
if [ "${cur_version:-}" != "$VERSION" ] || [ "${cur_sha:-}" != "$TAG_SHA" ] \
  || [ ! -d "${install_path:-/nonexistent}" ]; then
  log "installing $PLUGIN $VERSION from tag $TAG"
  claude plugin uninstall "$PLUGIN" >/dev/null 2>&1 || true
  claude plugin marketplace remove "$MARKETPLACE" >/dev/null 2>&1 || true
  claude plugin marketplace add "https://github.com/$REPO.git#$TAG" >&2
  claude plugin install "$PLUGIN" >&2
  read -r cur_version cur_sha install_path <<<"$(installed_info)" || true
fi

if [ "${cur_version:-}" != "$VERSION" ] || [ "${cur_sha:-}" != "$TAG_SHA" ] || [ ! -d "${install_path:-/nonexistent}" ]; then
  log "expected $VERSION at $TAG_SHA, found '${cur_version:-none}' at '${cur_sha:-none}'"
  exit 1
fi

# Fetch one LFS file. Args: <commit sha> <install dir> <marketplace dir> <relative path>
fetch_one() {
  local sha="$1" dest="$2" market="$3" rel="$4"
  local file="$dest/$rel" oid size enc tmp
  oid=$(sed -n 's/^oid sha256://p' "$file")
  size=$(sed -n 's/^size //p' "$file")
  enc=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$rel")
  tmp="$file.lfs-tmp"
  if curl -sSfL --retry 3 --retry-delay 2 -o "$tmp" \
      "https://media.githubusercontent.com/media/heygen-com/hyperframes/$sha/$enc" \
    && [ "$(stat -c %s "$tmp")" = "$size" ] \
    && [ "$(sha256sum "$tmp" | cut -d' ' -f1)" = "$oid" ]; then
    mv "$tmp" "$file"
    # Keep the marketplace clone in sync when it holds the same pointer.
    if [ -f "$market/$rel" ] && grep -q "^oid sha256:$oid" "$market/$rel" 2>/dev/null; then
      cp "$file" "$market/$rel"
    fi
  else
    rm -f "$tmp"
    echo "FAIL $rel" >&2
    return 1
  fi
}
export -f fetch_one

pointers=$(cd "$install_path" && grep -rlI "$LFS_HEADER" . 2>/dev/null | sed 's|^\./||' || true)
count=$(printf '%s' "$pointers" | grep -c . || true)

if [ "$count" -eq 0 ]; then
  log "$PLUGIN $VERSION ready, no LFS pointer files left"
  exit 0
fi

log "downloading $count LFS files with $JOBS parallel jobs"
if printf '%s\n' "$pointers" \
  | xargs -d '\n' -P "$JOBS" -I{} bash -c 'fetch_one "$@"' _ "$cur_sha" "$install_path" "$MARKET_DIR" {}; then
  log "$PLUGIN $VERSION ready, $count LFS files downloaded and verified"
else
  left=$(cd "$install_path" && grep -rlI "$LFS_HEADER" . 2>/dev/null | wc -l)
  log "$left LFS files still missing, rerun this script to retry"
  exit 1
fi
