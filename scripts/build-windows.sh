#!/usr/bin/env bash
# Package Alg0rithm as a Windows portable app
# Uses fetched web/ assets + a launcher (Edge/WebView2 / default browser offline folder)

set -euo pipefail

VERSION="${VERSION:-3.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_APP="$ROOT/web/app"
BUILD="$ROOT/build/windows"
OUT="$ROOT/dist"
APP_DIR="$BUILD/Alg0rithm"

rm -rf "$BUILD"
mkdir -p "$APP_DIR" "$OUT"

# Ensure web assets exist
if [[ ! -d "$WEB_APP" ]]; then
  chmod +x "$ROOT/scripts/fetch-web.sh"
  "$ROOT/scripts/fetch-web.sh"
fi

# Copy full web app for offline use
cp -a "$WEB_APP/." "$APP_DIR/app/"

# Windows launcher (.bat) – opens local index.html in default browser
cat > "$APP_DIR/Alg0rithm.bat" << 'EOF'
@echo off
setlocal
set "HERE=%~dp0"
set "INDEX=%HERE%app\index.html"
if exist "%INDEX%" (
  start "" "%INDEX%"
) else (
  start "" "https://alg0rithm.dev"
)
endlocal
EOF

# PowerShell launcher (cleaner)
cat > "$APP_DIR/Alg0rithm.ps1" << 'EOF'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$index = Join-Path $here "app\index.html"
if (Test-Path $index) {
  Start-Process $index
} else {
  Start-Process "https://alg0rithm.dev"
}
EOF

# README for users
cat > "$APP_DIR/README.txt" << EOF
Alg0rithm $VERSION – Windows portable

1. Double-click Alg0rithm.bat to open the app.
2. The full site is inside the app\ folder (works offline after first load of assets).
3. Source: https://github.com/hammuod/Alg0rithm
EOF

# Zip as portable package
cd "$BUILD"
if command -v zip >/dev/null 2>&1; then
  zip -r "$OUT/Alg0rithm-${VERSION}-windows-portable.zip" Alg0rithm
elif command -v powershell >/dev/null 2>&1; then
  powershell -Command "Compress-Archive -Path 'Alg0rithm' -DestinationPath '$OUT/Alg0rithm-${VERSION}-windows-portable.zip' -Force"
else
  tar -czf "$OUT/Alg0rithm-${VERSION}-windows-portable.tar.gz" Alg0rithm
fi

cd "$OUT"
for f in Alg0rithm-${VERSION}-windows-portable.*; do
  [[ -f "$f" ]] || continue
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" > "${f}.sha256"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" > "${f}.sha256"
  fi
done

echo "Windows package ready in dist/"
ls -lh "$OUT"/*windows* 2>/dev/null || ls -lh "$OUT"
