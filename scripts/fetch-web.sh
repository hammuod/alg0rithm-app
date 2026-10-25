#!/usr/bin/env bash
# Pull the real Alg0rithm web app from the main repository
# and place it under web/ for packaging into native apps.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB="$ROOT/web"
SRC_REPO="https://github.com/hammuod/Alg0rithm.git"
SRC_BRANCH="main"

rm -rf "$WEB"
mkdir -p "$WEB"

echo "Fetching Alg0rithm from $SRC_REPO ($SRC_BRANCH)..."

if command -v git >/dev/null 2>&1; then
  git clone --depth 1 --branch "$SRC_BRANCH" "$SRC_REPO" "$WEB/repo"
  # Copy only runtime assets (no .git, no CI)
  rsync -a --exclude='.git' --exclude='.github' --exclude='node_modules' \
    "$WEB/repo/" "$WEB/app/" 2>/dev/null || cp -a "$WEB/repo/." "$WEB/app/"
  rm -rf "$WEB/repo"
else
  # Fallback: sparse download of key files via raw github
  mkdir -p "$WEB/app"
  for f in index.html lap.html docs.html sw.js package.json; do
    curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/$f" \
      -o "$WEB/app/$f" 2>/dev/null || true
  done
fi

# Marker for packagers
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$WEB/.fetched"
echo "Web app ready at: $WEB/app"
ls -la "$WEB/app" | head -20
