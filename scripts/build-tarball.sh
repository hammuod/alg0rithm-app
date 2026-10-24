#!/usr/bin/env bash
# Universal source / binary tarball – works on ANY Linux distro
# (Void, Gentoo, Slackware, NixOS manual install, etc.)

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/tarball"
OUT="$ROOT/dist"
PREFIX="$BUILD/${PKG_NAME}-${VERSION}"

rm -rf "$BUILD"
mkdir -p "$PREFIX/bin" \
         "$PREFIX/share/applications" \
         "$PREFIX/share/icons/hicolor/256x256/apps" \
         "$OUT"

cat > "$PREFIX/bin/alg0rithm" << 'EOF'
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
chmod 755 "$PREFIX/bin/alg0rithm"

cp "$ROOT/packaging/deb/alg0rithm.desktop" "$PREFIX/share/applications/"
curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
  -o "$PREFIX/share/icons/hicolor/256x256/apps/alg0rithm.png" 2>/dev/null || true

# Simple install helper inside the tarball
cat > "$PREFIX/install.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
DEST="${1:-$HOME/.local}"
mkdir -p "$DEST/bin" "$DEST/share/applications" \
         "$DEST/share/icons/hicolor/256x256/apps"
cp -f bin/alg0rithm "$DEST/bin/"
cp -f share/applications/alg0rithm.desktop "$DEST/share/applications/"
cp -f share/icons/hicolor/256x256/apps/alg0rithm.png \
      "$DEST/share/icons/hicolor/256x256/apps/" 2>/dev/null || true
# Fix Exec path for user install
sed -i "s|^Exec=.*|Exec=$DEST/bin/alg0rithm|" \
  "$DEST/share/applications/alg0rithm.desktop"
echo "Installed to $DEST – run: alg0rithm"
EOF
chmod 755 "$PREFIX/install.sh"

tar -C "$BUILD" -czf "$OUT/${PKG_NAME}-${VERSION}-linux-any.tar.gz" "${PKG_NAME}-${VERSION}"
sha256sum "$OUT/${PKG_NAME}-${VERSION}-linux-any.tar.gz" \
  > "$OUT/${PKG_NAME}-${VERSION}-linux-any.tar.gz.sha256"

echo "Universal tarball: $OUT/${PKG_NAME}-${VERSION}-linux-any.tar.gz"
ls -lh "$OUT/${PKG_NAME}-${VERSION}-linux-any.tar.gz"
