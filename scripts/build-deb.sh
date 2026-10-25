#!/usr/bin/env bash
# Build .deb with embedded Alg0rithm web app (offline)
set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_APP="$ROOT/web/app"
BUILD="$ROOT/build/deb"
OUT="$ROOT/dist"

if [[ ! -d "$WEB_APP" ]]; then
  chmod +x "$ROOT/scripts/fetch-web.sh"
  "$ROOT/scripts/fetch-web.sh"
fi

rm -rf "$BUILD"
mkdir -p "$BUILD/DEBIAN" \
         "$BUILD/usr/bin" \
         "$BUILD/usr/share/$PKG_NAME" \
         "$BUILD/usr/share/applications" \
         "$BUILD/usr/share/icons/hicolor/256x256/apps" \
         "$BUILD/usr/share/doc/$PKG_NAME" \
         "$OUT"

cp "$ROOT/packaging/deb/control" "$BUILD/DEBIAN/control"
sed -i "s/^Version:.*/Version: $VERSION/" "$BUILD/DEBIAN/control"
cp "$ROOT/packaging/deb/postinst" "$BUILD/DEBIAN/postinst"
chmod 755 "$BUILD/DEBIAN/postinst"

# Embed web app
cp -a "$WEB_APP/." "$BUILD/usr/share/$PKG_NAME/"

# Launcher opens local copy
cat > "$BUILD/usr/bin/$PKG_NAME" << EOF
#!/usr/bin/env bash
INDEX="/usr/share/${PKG_NAME}/index.html"
if [[ -f "\$INDEX" ]] && command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "\$INDEX"
elif command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "https://alg0rithm.dev"
else
  echo "Open: \$INDEX"
fi
EOF
chmod 755 "$BUILD/usr/bin/$PKG_NAME"

cp "$ROOT/packaging/deb/alg0rithm.desktop" "$BUILD/usr/share/applications/"
curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
  -o "$BUILD/usr/share/icons/hicolor/256x256/apps/${PKG_NAME}.png" 2>/dev/null || true

cat > "$BUILD/usr/share/doc/$PKG_NAME/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: Alg0rithm
Source: https://github.com/hammuod/Alg0rithm
Copyright: Hammoud (hammuod)
License: AGPL-3.0
EOF

dpkg-deb --build --root-owner-group "$BUILD" "$OUT/${PKG_NAME}_${VERSION}_all.deb"
sha256sum "$OUT/${PKG_NAME}_${VERSION}_all.deb" > "$OUT/${PKG_NAME}_${VERSION}_all.deb.sha256"
echo "Built DEB with embedded web app."
ls -lh "$OUT"/*.deb
