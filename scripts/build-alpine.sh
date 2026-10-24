#!/usr/bin/env bash
# Prepare Alpine Linux package sources

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/alpine"
OUT="$ROOT/dist"

rm -rf "$BUILD"
mkdir -p "$BUILD" "$OUT"

cp "$ROOT/packaging/alpine/APKBUILD" "$BUILD/"
sed -i "s/^pkgver=.*/pkgver=$VERSION/" "$BUILD/APKBUILD"

cat > "$BUILD/alg0rithm" << 'EOF'
#!/usr/bin/env bash
URL="https://alg0rithm.dev"
if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "$URL"
elif command -v gio >/dev/null 2>&1; then
  exec gio open "$URL"
else
  echo "Open: $URL"
fi
EOF
chmod 755 "$BUILD/alg0rithm"

cp "$ROOT/packaging/deb/alg0rithm.desktop" "$BUILD/"
curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
  -o "$BUILD/icon.png" 2>/dev/null || true

tar -C "$BUILD" -czf "$OUT/${PKG_NAME}-${VERSION}-alpine.src.tar.gz" \
  APKBUILD alg0rithm alg0rithm.desktop icon.png 2>/dev/null || \
tar -C "$BUILD" -czf "$OUT/${PKG_NAME}-${VERSION}-alpine.src.tar.gz" \
  APKBUILD alg0rithm alg0rithm.desktop

sha256sum "$OUT/${PKG_NAME}-${VERSION}-alpine.src.tar.gz" \
  > "$OUT/${PKG_NAME}-${VERSION}-alpine.src.tar.gz.sha256"

echo "Alpine source package ready."
