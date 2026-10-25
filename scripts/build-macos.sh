#!/usr/bin/env bash
# Package Alg0rithm as a macOS .app bundle (portable zip)
# Free runner: macos-latest

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_APP="$ROOT/web/app"
BUILD="$ROOT/build/macos"
OUT="$ROOT/dist"
APP="$BUILD/Alg0rithm.app"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" \
         "$APP/Contents/Resources/app" \
         "$OUT"

if [[ ! -d "$WEB_APP" ]]; then
  chmod +x "$ROOT/scripts/fetch-web.sh"
  "$ROOT/scripts/fetch-web.sh"
fi

cp -a "$WEB_APP/." "$APP/Contents/Resources/app/"

# Launcher script inside .app
cat > "$APP/Contents/MacOS/Alg0rithm" << 'EOF'
#!/bin/bash
HERE="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$HERE/Resources/app/index.html"
if [[ -f "$INDEX" ]]; then
  open "$INDEX"
else
  open "https://alg0rithm.dev"
fi
EOF
chmod +x "$APP/Contents/MacOS/Alg0rithm"

# Info.plist
cat > "$APP/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Alg0rithm</string>
  <key>CFBundleDisplayName</key>
  <string>Alg0rithm</string>
  <key>CFBundleIdentifier</key>
  <string>dev.alg0rithm.app</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleExecutable</key>
  <string>Alg0rithm</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>10.13</string>
</dict>
</plist>
EOF

# Zip the .app
cd "$BUILD"
zip -r "$OUT/Alg0rithm-${VERSION}-macos.zip" Alg0rithm.app
sha256sum "$OUT/Alg0rithm-${VERSION}-macos.zip" > "$OUT/Alg0rithm-${VERSION}-macos.zip.sha256" 2>/dev/null \
  || shasum -a 256 "$OUT/Alg0rithm-${VERSION}-macos.zip" > "$OUT/Alg0rithm-${VERSION}-macos.zip.sha256"

echo "macOS package ready."
ls -lh "$OUT"/*macos*
