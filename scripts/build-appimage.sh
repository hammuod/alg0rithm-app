#!/usr/bin/env bash
# Build a portable AppImage (no root, works on almost every Linux)
# Uses free tools only.

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/appimage"
OUT="$ROOT/dist"
APPDIR="$BUILD/Alg0rithm.AppDir"

rm -rf "$BUILD"
mkdir -p "$APPDIR/usr/bin" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$OUT"

# binary
cat > "$APPDIR/usr/bin/alg0rithm" << 'EOF'
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
chmod 755 "$APPDIR/usr/bin/alg0rithm"

# desktop + AppRun
cp "$ROOT/packaging/deb/alg0rithm.desktop" "$APPDIR/"
cp "$ROOT/packaging/deb/alg0rithm.desktop" "$APPDIR/usr/share/applications/"
cp "$ROOT/packaging/appimage/AppRun" "$APPDIR/AppRun"
chmod 755 "$APPDIR/AppRun"

# icon
curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
  -o "$APPDIR/alg0rithm.png" 2>/dev/null || true
cp "$APPDIR/alg0rithm.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/" 2>/dev/null || true
ln -sf alg0rithm.png "$APPDIR/.DirIcon" 2>/dev/null || true

echo "AppDir prepared at $APPDIR"
echo "To finish AppImage you need appimagetool (downloaded free in CI)."
echo "Placeholder tarball created for now."

tar -C "$BUILD" -czf "$OUT/Alg0rithm-${VERSION}-x86_64.AppDir.tar.gz" Alg0rithm.AppDir
ls -lh "$OUT/Alg0rithm-${VERSION}-x86_64.AppDir.tar.gz"
