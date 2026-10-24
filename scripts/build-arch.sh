#!/usr/bin/env bash
# Prepare Arch Linux package sources (PKGBUILD + files)
# Users / CI can build with makepkg on Arch; we also ship a ready source tarball.

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/arch"
OUT="$ROOT/dist"

rm -rf "$BUILD"
mkdir -p "$BUILD" "$OUT"

cp "$ROOT/packaging/arch/PKGBUILD" "$BUILD/"
sed -i "s/^pkgver=.*/pkgver=$VERSION/" "$BUILD/PKGBUILD"

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

# Source package for AUR / local makepkg
tar -C "$BUILD" -czf "$OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz" \
  PKGBUILD alg0rithm alg0rithm.desktop icon.png 2>/dev/null || \
tar -C "$BUILD" -czf "$OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz" \
  PKGBUILD alg0rithm alg0rithm.desktop

sha256sum "$OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz" \
  > "$OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz.sha256"

echo "Arch source package: $OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz"
ls -lh "$OUT/${PKG_NAME}-${VERSION}-arch.src.tar.gz"
