#!/usr/bin/env bash
# Build .rpm for Fedora / RHEL / Rocky / Alma / openSUSE (noarch)
# Runs on Ubuntu free runners using rpmbuild.

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
PKG_NAME="alg0rithm"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/rpm"
OUT="$ROOT/dist"
TOPDIR="$BUILD/rpmbuild"

rm -rf "$BUILD"
mkdir -p "$TOPDIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS} "$OUT"

# Prepare source tree
SRC="$BUILD/${PKG_NAME}-${VERSION}"
mkdir -p "$SRC"

cat > "$SRC/alg0rithm" << 'EOF'
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
chmod 755 "$SRC/alg0rithm"

cp "$ROOT/packaging/deb/alg0rithm.desktop" "$SRC/"
curl -fsSL "https://raw.githubusercontent.com/hammuod/Alg0rithm/main/imgs/icon.png" \
  -o "$SRC/icon.png" 2>/dev/null || true

tar -C "$BUILD" -czf "$TOPDIR/SOURCES/${PKG_NAME}-${VERSION}.tar.gz" "${PKG_NAME}-${VERSION}"

# Spec
cp "$ROOT/packaging/rpm/alg0rithm.spec" "$TOPDIR/SPECS/"
sed -i "s/^Version:.*/Version:        $VERSION/" "$TOPDIR/SPECS/alg0rithm.spec"

# Install rpm tools if missing (Ubuntu)
if ! command -v rpmbuild >/dev/null 2>&1; then
  echo "Installing rpm build tools..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq rpm
fi

rpmbuild --define "_topdir $TOPDIR" -bb "$TOPDIR/SPECS/alg0rithm.spec"

# Copy result
find "$TOPDIR/RPMS" -name "*.rpm" -exec cp {} "$OUT/" \;
ls -lh "$OUT"/*.rpm 2>/dev/null || true
for f in "$OUT"/*.rpm; do
  [[ -f "$f" ]] || continue
  sha256sum "$f" > "${f}.sha256"
  cat "${f}.sha256"
done

echo "RPM build done."
