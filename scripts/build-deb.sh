#!/usr/bin/env bash
# Build a real .deb package for Alg0rithm (Architecture: all)
# Runs on Ubuntu free runners – no paid services.

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/deb"
OUT="$ROOT/dist"

rm -rf "$BUILD"
mkdir -p "$BUILD/DEBIAN" \
         "$BUILD/usr/bin" \
         "$BUILD/usr/share/applications" \
         "$BUILD/usr/share/icons/hicolor/256x256/apps" \
         "$BUILD/usr/share/doc/$PKG_NAME" \
         "$OUT"

# control
cp "$ROOT/packaging/deb/control" "$BUILD/DEBIAN/control"
sed -i "s/^Version:.*/Version: $VERSION/" "$BUILD/DEBIAN/control"

# postinst
cp "$ROOT/packaging/deb/postinst" "$BUILD/DEBIAN/postinst"
chmod 755 "$BUILD/DEBIAN/postinst"

# binary wrapper
cat > "$BUILD/usr/bin/$PKG_NAME" << 'EOF'
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
chmod 755 "$BUILD/usr/bin/$PKG_NAME"

# desktop file
cp "$ROOT/packaging/deb/alg0rithm.desktop" "$BUILD/usr/share/applications/"

# icon (best effort)
if curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
     -o "$BUILD/usr/share/icons/hicolor/256x256/apps/${PKG_NAME}.png" 2>/dev/null; then
  echo "Icon embedded"
fi

# docs
cat > "$BUILD/usr/share/doc/$PKG_NAME/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: Alg0rithm
Source: https://github.com/hammuod/Alg0rithm

Files: *
Copyright: Hammoud (hammuod)
License: AGPL-3.0
EOF

# build
dpkg-deb --build --root-owner-group "$BUILD" "$OUT/${PKG_NAME}_${VERSION}_all.deb"

echo "Built: $OUT/${PKG_NAME}_${VERSION}_all.deb"
ls -lh "$OUT/${PKG_NAME}_${VERSION}_all.deb"
sha256sum "$OUT/${PKG_NAME}_${VERSION}_all.deb" > "$OUT/${PKG_NAME}_${VERSION}_all.deb.sha256"
cat "$OUT/${PKG_NAME}_${VERSION}_all.deb.sha256"
